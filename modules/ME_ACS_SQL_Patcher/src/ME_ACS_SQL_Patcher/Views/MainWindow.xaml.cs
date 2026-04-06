using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Diagnostics;
using System.IO;
using System.Globalization;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;
using System.Windows.Media.Animation;
using System.Windows.Threading;
using MagDbPatcher.Infrastructure;
using MagDbPatcher.Models;
using MagDbPatcher.Services;
using MagDbPatcher.ViewModels;
using MagDbPatcher.Workflows;
using Microsoft.Win32;

namespace MagDbPatcher;

public partial class MainWindow : Window
{
    private readonly MainViewModel _viewModel = new();
    private readonly AppRuntimePaths _appPaths;
    private readonly IAppSettingsService _settingsService;
    private readonly IPatchStorageService _patchStorageService;
    private readonly IUserDialogService _dialogs = new UserDialogService();
    private readonly RunRequestBuilder _requestBuilder;
    private readonly SettingsBinder _settingsBinder;
    private readonly RunSummaryComposer _runSummaryComposer = new();
    private readonly RunUiStateController _runUiStateController = new();
    private readonly RunStateEvaluator _runStateEvaluator = new();
    private readonly SqlConnectionTestCoordinator _sqlConnectionTestCoordinator = new();
    private readonly RunExecutionPresenter _runExecutionPresenter = new();
    private readonly RunDiagnosticsCoordinator _runDiagnosticsCoordinator = new();
    private readonly RunWarningFormatter _runWarningFormatter = new();
    private readonly SessionLog _sessionLog;
    private readonly IMainRunOrchestrator _runOrchestrator;
    private readonly List<SqlBatchWarning> _runWarningDetails = new();
    private readonly Queue<string> _pendingLogLines = new();
    private readonly Queue<string> _visibleLogLines = new();
    private readonly Queue<string> _retainedLogLines = new();
    private readonly DispatcherTimer _logFlushTimer = new() { Interval = TimeSpan.FromMilliseconds(150) };
    private const int MaxVisibleLogLines = 400;
    private const int MaxRetainedLogLines = 4000;

    private AppSettings _settings = new();
    private IVersionService? _versionService;
    private PatchPackImportCoordinator? _patchImportCoordinator;
    private PatchCatalogDescriptor? _activePatchCatalog;
    private CancellationTokenSource? _runCancellation;
    private AdminWindow? _adminWindow;
    private string _bundledPatchesFolder = "";
    private string _managedPatchesFolder = "";
    private string _lastOutputPath = "";
    private bool _isLoadingUi;
    private bool _isUiInitialized;

    public MainWindow()
        : this(new MainRunOrchestrator(), AppRuntimePaths.CreateDefault())
    {
    }

    internal MainWindow(AppRuntimePaths appPaths)
        : this(new MainRunOrchestrator(), appPaths)
    {
    }

    internal MainWindow(IMainRunOrchestrator runOrchestrator, AppRuntimePaths? appPaths = null)
    {
        _appPaths = appPaths ?? AppRuntimePaths.CreateDefault();
        _settingsService = new AppSettingsService(_appPaths);
        _patchStorageService = new PatchStorageService(_appPaths);
        _requestBuilder = new RunRequestBuilder(_appPaths);
        _settingsBinder = new SettingsBinder(_appPaths);
        _sessionLog = new SessionLog(_appPaths);

        InitializeComponent();
        _runOrchestrator = runOrchestrator;

        DataContext = _viewModel;

        cmbSourcePath.ItemsSource = _viewModel.RecentBackupFiles;
        cmbFromVersion.ItemsSource = _viewModel.SourceVersions;
        cmbToVersion.ItemsSource = _viewModel.TargetVersions;
        lstValidationIssues.ItemsSource = _viewModel.ValidationIssues;
        lstRunWarnings.ItemsSource = _viewModel.RunWarnings;

        lstValidationIssues.DisplayMemberPath = nameof(ValidationIssue.Message);
        cmbSourcePath.LostFocus += (_, _) => RefreshRunSummary();
        cmbSqlServer.LostFocus += (_, _) => RefreshRunSummary();
        cmbSourcePath.AddHandler(TextBox.TextChangedEvent, new TextChangedEventHandler(EditableComboTextChanged));
        cmbSqlServer.AddHandler(TextBox.TextChangedEvent, new TextChangedEventHandler(EditableComboTextChanged));
        _logFlushTimer.Tick += (_, _) => FlushPendingLogLines();

        Loaded += MainWindow_Loaded;
        Closing += MainWindow_Closing;

        ApplyReadyState();
        _isUiInitialized = true;
    }

    private async void MainWindow_Loaded(object sender, RoutedEventArgs e)
    {
        _isLoadingUi = true;
        try
        {
            _bundledPatchesFolder = _appPaths.BundledPatchesFolder;
            _managedPatchesFolder = _patchStorageService.GetDefaultPatchesFolder();
            _settings = await _settingsService.LoadAsync();
            var initialPatchesFolder = await _patchStorageService.ResolvePatchesFolderAsync(_settings, _bundledPatchesFolder);
            await RefreshManagedLibraryFromBundledIfSafeAsync(initialPatchesFolder);

            ApplySettingsToUi();
            _viewModel.StatusText = "Loading SQL Server suggestions...";
            await LoadSqlServerSuggestionsAsync();
            _viewModel.StatusText = "Loading patch library...";
            await SetPatchesFolderAsync(initialPatchesFolder, closeAdminWindow: false);
            _sessionLog.WriteLine($"[{DateTime.Now:HH:mm:ss}] App started. Install: {_appPaths.AppInstallDirectory} Data: {_appPaths.UserDataDirectory}");
            RefreshRunSummary();
            await PersistSettingsAsync();
            FocusPrimaryInput();
            _viewModel.StatusText = "Ready";
        }
        catch (Exception ex)
        {
            _sessionLog.WriteLine($"[{DateTime.Now:HH:mm:ss}] Startup failed: {ex.Message}");
            _dialogs.ShowError($"Startup failed: {ex.Message}", "Startup Error");
            SetBanner(NotificationLevel.Error, "Startup failed. See error message.");
        }
        finally
        {
            _isLoadingUi = false;
        }
    }

    private async void MainWindow_Closing(object? sender, CancelEventArgs e)
    {
        if (_runCancellation != null)
        {
            if (!_dialogs.Confirm(
                    "A patch run is still in progress. Cancel it and close the app?",
                    "Close Application",
                    useYesNo: true))
            {
                e.Cancel = true;
                return;
            }

            _runCancellation.Cancel();
        }

        if (_adminWindow != null)
        {
            _adminWindow.Close();
            _adminWindow = null;
        }

        await PersistSettingsAsync();
    }

    private void ApplyReadyState()
    {
        _viewModel.PatchVersionText = "";
        _viewModel.AppBuildText = AppMetadata.BuildLabel;
        _viewModel.StatusText = "Loading application workspace...";
        _viewModel.LogText = "";
        _viewModel.SqlTestResultText = "";
        _viewModel.SourceFileHintText = "";
        _viewModel.UpgradePathText = "";
        _visibleLogLines.Clear();
        _retainedLogLines.Clear();
        _pendingLogLines.Clear();

        _viewModel.ProgressValue = 0;
        _viewModel.ClearValidation();
        _viewModel.NotificationMessage = "";
        _viewModel.NotificationLevel = NotificationLevel.None;
        _viewModel.ClearRunWarnings();
        _runWarningDetails.Clear();
        UpdateWarningChip(0);
        bdStatusBanner.Visibility = Visibility.Collapsed;
        ApplyRunExecutionState(_runExecutionPresenter.BuildInitialState());

        btnRetryFromValidation.IsEnabled = false;
        btnRetryFromValidation.Visibility = Visibility.Collapsed;
        btnCopyDiagnostics.IsEnabled = false;
        btnCopyDiagnostics.Visibility = Visibility.Collapsed;
        btnOpenOutputFolder.IsEnabled = false;
        btnOpenOutputFolder.Visibility = Visibility.Collapsed;
        btnCancel.IsEnabled = false;

        Title = $"{AppMetadata.Title} {AppMetadata.DisplayVersion}";
        ApplyGuidanceState(StepGuidanceState.Initial);
    }

    private void ApplySettingsToUi()
    {
        var snapshot = _settingsBinder.BuildViewSnapshot(_settings);

        _viewModel.RecentBackupFiles.Clear();
        foreach (var item in snapshot.RecentBackups)
            _viewModel.RecentBackupFiles.Add(item);

        if (_viewModel.RecentBackupFiles.Count > 0)
        {
            cmbSourcePath.SelectedIndex = 0;
            txtSourcePlaceholder.Visibility = Visibility.Collapsed;
        }

        cmbSqlServer.Text = snapshot.LastSqlServer;
        txtSqlUsername.Text = snapshot.SqlUsername;
        txtTempFolder.Text = snapshot.PatchTempFolder;
        txtWarningThreshold.Text = snapshot.WarningThreshold.ToString(CultureInfo.InvariantCulture);
        cmbErrorMode.SelectedValue = snapshot.PatchErrorMode;

        rbAuthSql.IsChecked = snapshot.SqlAuthMode == SqlAuthMode.SqlLogin;
        rbAuthWindows.IsChecked = snapshot.SqlAuthMode != SqlAuthMode.SqlLogin;
        UpdateAuthModeUi();
        RefreshPatchLibrarySummary(snapshot.LastImportedPack);

        ThemeService.Apply(_settings.IsDarkTheme);
        btnToggleTheme.Content = _settings.IsDarkTheme ? "Light Mode" : "Dark Mode";
    }

    private string GetCurrentPatchesFolder()
    {
        if (!string.IsNullOrWhiteSpace(txtPatchesFolder.Text))
            return txtPatchesFolder.Text.Trim();
        if (!string.IsNullOrWhiteSpace(_settings.PatchesFolder))
            return _settings.PatchesFolder!;
        return _patchStorageService.GetDefaultPatchesFolder();
    }

    private async Task LoadSqlServerSuggestionsAsync()
    {
        var serverService = new SqlServerService(".");
        var discovered = await serverService.GetAvailableSqlServersAsync();

        var suggestions = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
        {
            ".",
            "localhost",
            "(local)",
            ".\\SQLEXPRESS",
            "(localdb)\\MSSQLLocalDB",
            ".\\MAGSQL"
        };

        foreach (var server in discovered)
            suggestions.Add(server);

        if (!string.IsNullOrWhiteSpace(_settings.LastSqlServer))
            suggestions.Add(_settings.LastSqlServer);

        cmbSqlServer.ItemsSource = suggestions.OrderBy(s => s, StringComparer.OrdinalIgnoreCase).ToList();
        if (string.IsNullOrWhiteSpace(cmbSqlServer.Text))
            cmbSqlServer.Text = ".\\MAGSQL";
    }

    private async Task SetPatchesFolderAsync(string folder, bool closeAdminWindow = true)
    {
        var normalized = string.IsNullOrWhiteSpace(folder)
            ? _managedPatchesFolder
            : Path.GetFullPath(folder.Trim());

        if (!Directory.Exists(normalized))
            Directory.CreateDirectory(normalized);

        txtPatchesFolder.Text = normalized;
        _settings.PatchesFolder = normalized;

        _versionService = new VersionService(normalized);
        await _versionService.LoadVersionsAsync();
        _runOrchestrator.UpdateVersionService(_versionService);
        _activePatchCatalog = PatchCatalogDescriptorBuilder.FromVersionService(_versionService);

        _patchImportCoordinator = new PatchPackImportCoordinator(new PatchPackService(_appPaths.BackupsDirectory, _appPaths.ImportedPacksDirectory));

        if (closeAdminWindow && _adminWindow != null)
        {
            _adminWindow.Close();
            _adminWindow = null;
        }

        RefreshVersionSelectors(tryPreserveSelection: true);
        RefreshPatchLibrarySummary(_settings.LastImportedPatchPack);
        RefreshRunSummary();
    }

    private void RefreshPatchLibrarySummary(string? lastImportedPack)
    {
        var currentFolder = string.IsNullOrWhiteSpace(txtPatchesFolder?.Text)
            ? _patchStorageService.GetDefaultPatchesFolder()
            : txtPatchesFolder.Text.Trim();

        var mode = string.Equals(currentFolder, _managedPatchesFolder, StringComparison.OrdinalIgnoreCase)
            ? "Managed patch library"
            : "Custom patch library";

        var importText = string.IsNullOrWhiteSpace(lastImportedPack)
            ? "Last imported pack: none yet."
            : $"Last imported pack: {lastImportedPack}.";

        txtLastImportedPack.Text = $"{mode}: {currentFolder}{Environment.NewLine}{importText}";
    }

    private void RefreshVersionSelectors(bool tryPreserveSelection)
    {
        if (_versionService == null)
            return;

        var previousFrom = tryPreserveSelection ? GetSelectedVersionId(cmbFromVersion) : null;
        var previousTo = tryPreserveSelection ? GetSelectedVersionId(cmbToVersion) : null;

        _viewModel.SourceVersions.Clear();
        foreach (var version in _versionService.GetSourceVersions())
            _viewModel.SourceVersions.Add(version);

        if (!string.IsNullOrWhiteSpace(previousFrom))
        {
            cmbFromVersion.SelectedItem = _viewModel.SourceVersions.FirstOrDefault(v =>
                string.Equals(v.Id, previousFrom, StringComparison.OrdinalIgnoreCase));
        }

        if (cmbFromVersion.SelectedItem == null && _viewModel.SourceVersions.Count > 0)
            cmbFromVersion.SelectedIndex = 0;

        RefreshTargetVersions(previousTo);
        RefreshPatchVersionBadge();
    }

    private void RefreshPatchVersionBadge()
    {
        if (_versionService == null || _activePatchCatalog == null)
        {
            _viewModel.PatchVersionText = "";
            return;
        }

        _viewModel.PatchVersionText = $"Patch catalog { _activePatchCatalog.Label }";
    }

    private async Task RefreshManagedLibraryFromBundledIfSafeAsync(string initialPatchesFolder)
    {
        if (!string.Equals(
                Path.GetFullPath(initialPatchesFolder),
                Path.GetFullPath(_managedPatchesFolder),
                StringComparison.OrdinalIgnoreCase))
        {
            return;
        }

        var refreshed = await _patchStorageService.RefreshManagedLibraryFromBundledIfSafeAsync(
            initialPatchesFolder,
            _bundledPatchesFolder,
            hasImportedPack: !string.IsNullOrWhiteSpace(_settings.LastImportedPatchPack),
            bundledCatalogHash: AppMetadata.InstalledPatchCatalogHash);

        if (!refreshed)
            return;

        _sessionLog.WriteLine($"[{DateTime.Now:HH:mm:ss}] Managed patch library refreshed from bundled catalog.");
    }

    private void RefreshTargetVersions(string? preferredTargetId = null)
    {
        if (_versionService == null)
            return;

        var fromVersionId = GetSelectedVersionId(cmbFromVersion);
        _viewModel.TargetVersions.Clear();

        if (string.IsNullOrWhiteSpace(fromVersionId))
            return;

        foreach (var version in _versionService.GetTargetVersions(fromVersionId))
            _viewModel.TargetVersions.Add(version);

        if (!string.IsNullOrWhiteSpace(preferredTargetId))
        {
            cmbToVersion.SelectedItem = _viewModel.TargetVersions.FirstOrDefault(v =>
                string.Equals(v.Id, preferredTargetId, StringComparison.OrdinalIgnoreCase));
        }

        if (cmbToVersion.SelectedItem == null && _viewModel.TargetVersions.Count > 0)
            cmbToVersion.SelectedIndex = _viewModel.TargetVersions.Count - 1;

        UpdateUpgradePathText();
    }

    private static string? GetSelectedVersionId(ComboBox comboBox)
    {
        if (comboBox.SelectedItem is VersionInfo versionInfo)
            return versionInfo.Id;
        return comboBox.SelectedValue as string;
    }

    private void UpdateUpgradePathText()
    {
        if (_versionService == null)
        {
            bdUpgradePath.Visibility = Visibility.Collapsed;
            return;
        }

        var fromVersion = GetSelectedVersionId(cmbFromVersion);
        var toVersion = GetSelectedVersionId(cmbToVersion);

        if (string.IsNullOrWhiteSpace(fromVersion) || string.IsNullOrWhiteSpace(toVersion))
        {
            bdUpgradePath.Visibility = Visibility.Collapsed;
            return;
        }

        try
        {
            var steps = _versionService.CalculateUpgradePath(fromVersion, toVersion);
            var totalScripts = steps.Sum(s => s.Scripts.Count);
            var segments = new List<string> { fromVersion };
            segments.AddRange(steps.Select(s => s.ToVersion));
            _viewModel.UpgradePathText = $"{string.Join("  →  ", segments)}" +
                $"    ({steps.Count} step{(steps.Count == 1 ? "" : "s")}, {totalScripts} script{(totalScripts == 1 ? "" : "s")})";
            txtUpgradePath.Foreground = (Brush)FindResource("TextPrimary");
        }
        catch (Exception ex)
        {
            _viewModel.UpgradePathText = $"No path available: {ex.Message}";
            txtUpgradePath.Foreground = (Brush)FindResource("Error");
        }

        bdUpgradePath.Visibility = Visibility.Visible;
    }

    private void RefreshRunSummary()
    {
        if (!_isUiInitialized ||
            txtRunSummarySource == null ||
            txtRunSummaryUpgradePath == null ||
            txtRunSummaryConnection == null ||
            txtRunSummaryOutput == null ||
            txtRunSummarySafeguards == null ||
            txtRunSummaryPlan == null ||
            cmbSourcePath == null ||
            cmbFromVersion == null ||
            cmbToVersion == null ||
            cmbSqlServer == null)
        {
            return;
        }

        SyncExecutionSettingsFromUi();
        ApplyRunSummaryState(BuildRunSummaryState());
        UpdateGuidanceUi();
    }

    private RunSummaryState BuildRunSummaryState()
    {
        var request = BuildRunRequest();
        return _runSummaryComposer.Compose(new RunSummaryInput(
            SourceBakPath: request.SourceBakPath,
            FromVersionId: request.FromVersionId,
            ToVersionId: request.ToVersionId,
            SqlServer: request.ConnectionSettings.Server,
            SqlAuthMode: request.ConnectionSettings.AuthMode,
            SqlConnectionTestPassed: _sqlConnectionTestCoordinator.MatchesLastSuccessfulSettings(request.ConnectionSettings),
            TempFolder: request.TempFolder,
            ErrorMode: request.ExecutionOptions.ErrorMode,
            WarningThreshold: request.ExecutionOptions.WarningThreshold,
            OutputBakPath: request.OutputBakPath,
            VersionService: _versionService));
    }

    private void ApplyRunSummaryState(RunSummaryState state)
    {
        _viewModel.SourceFileHintText = state.SourceFileHint;
        _viewModel.SourceFileHintKind = state.SourceFileHintKind;
        txtSourceFileHint.Foreground = state.SourceFileHintKind switch
        {
            SourceFileHintKind.Error => (Brush)FindResource("Error"),
            SourceFileHintKind.Success => (Brush)FindResource("Success"),
            _ => (Brush)FindResource("TextMuted")
        };

        _viewModel.RunSummarySource = state.SourceText;
        _viewModel.RunSummaryUpgradePath = state.UpgradePathText;
        _viewModel.RunSummaryConnection = state.ConnectionText;
        _viewModel.RunSummaryOutput = state.OutputText;
        _viewModel.RunSummaryPlan = state.PlanText;
        _viewModel.RunSummarySafeguards = state.SafeguardsText;
    }

    private void UpdateGuidanceUi()
    {
        var state = EvaluateGuidanceState();
        ApplyGuidanceState(state);
    }

    private StepGuidanceState EvaluateGuidanceState()
    {
        var sourcePath = (cmbSourcePath.Text ?? "").Trim();
        var fromVersion = GetSelectedVersionId(cmbFromVersion);
        var toVersion = GetSelectedVersionId(cmbToVersion);
        var settings = BuildSqlConnectionSettings();
        _sqlConnectionTestCoordinator.InvalidateIfSettingsChanged(SqlConnectionTestCoordinator.BuildSignature(settings));

        var sourceExists = !string.IsNullOrWhiteSpace(sourcePath) && File.Exists(sourcePath);
        var sourcePathEntered = !string.IsNullOrWhiteSpace(sourcePath);
        var versionSelectionPresent = !string.IsNullOrWhiteSpace(fromVersion) && !string.IsNullOrWhiteSpace(toVersion);
        var versionPathValid = false;
        if (versionSelectionPresent && _versionService != null)
        {
            try
            {
                _ = _versionService.CalculateUpgradePath(fromVersion!, toVersion!);
                versionPathValid = true;
            }
            catch
            {
                versionPathValid = false;
            }
        }

        var localSql = !string.IsNullOrWhiteSpace(settings.Server) && LocalSqlValidator.IsLocalServer(settings.Server);
        var hasSqlUser = settings.AuthMode != SqlAuthMode.SqlLogin || !string.IsNullOrWhiteSpace(settings.Username);
        var hasSqlPassword = settings.AuthMode != SqlAuthMode.SqlLogin || !string.IsNullOrWhiteSpace(settings.Password);

        var state = _runStateEvaluator.Evaluate(new RunStateInput(
            SourcePathEntered: sourcePathEntered,
            SourceExists: sourceExists,
            VersionSelectionPresent: versionSelectionPresent,
            VersionPathValid: versionPathValid,
            LocalSqlServer: localSql,
            HasSqlUser: hasSqlUser,
            HasSqlPassword: hasSqlPassword,
            SqlConnectionTestPassed: _sqlConnectionTestCoordinator.IsConnectionTestPassed,
            RunEngineReady: _runOrchestrator.IsReady));

        if (state.RunReady)
        {
            var validation = ValidateCurrentRequest(requirePassword: true);
            if (!validation.IsValid)
            {
                return state with
                {
                    Step4State = RunStepState.NeedsAttention,
                    RunReady = false,
                    PatchHintText = "Review validation issues before starting."
                };
            }
        }

        return state;
    }

    private void ApplyGuidanceState(StepGuidanceState state)
    {
        SetStepStatusChip(bdStep1Status, txtStep1Status, RunStateEvaluator.GetStepText(state.Step1State), state.Step1State);
        SetStepStatusChip(bdStep2Status, txtStep2Status, RunStateEvaluator.GetStepText(state.Step2State), state.Step2State);
        SetStepStatusChip(bdStep3Status, txtStep3Status, RunStateEvaluator.GetStepText(state.Step3State), state.Step3State);
        SetStepStatusChip(bdStep4Status, txtStep4Status, state.RunReady ? "Ready" : RunStateEvaluator.GetStepText(state.Step4State), state.Step4State);

        SetStepCircle(bdStep1Circle, txtStep1Circle, txtStep1Label, state.Step1State);
        SetStepCircle(bdStep2Circle, txtStep2Circle, txtStep2Label, state.Step2State);
        SetStepCircle(bdStep3Circle, txtStep3Circle, txtStep3Label, state.Step3State);
        SetStepCircle(bdStep4Circle, txtStep4Circle, txtStep4Label, state.Step4State);

        _viewModel.NextActionText = state.RunReady
            ? "Next: Review the run summary, then click Start Patch."
            : state.NextActionText;
        _viewModel.PatchActionHint = state.RunReady
            ? "Ready to run. Review the patch path, output, and safeguards, then click Start Patch."
            : state.PatchHintText;

        if (_runCancellation == null)
            btnPatch.IsEnabled = state.RunReady;
    }

    private void SetStepStatusChip(Border border, TextBlock textBlock, string text, RunStepState state)
    {
        textBlock.Text = text;

        switch (state)
        {
            case RunStepState.Done:
                border.Background = (Brush)FindResource("SuccessSoft");
                border.BorderBrush = (Brush)FindResource("Success");
                textBlock.Foreground = (Brush)FindResource("Success");
                break;
            case RunStepState.Ready:
                border.Background = (Brush)FindResource("InfoSoft");
                border.BorderBrush = (Brush)FindResource("Info");
                textBlock.Foreground = (Brush)FindResource("Info");
                break;
            case RunStepState.NeedsAttention:
                border.Background = (Brush)FindResource("WarningSoft");
                border.BorderBrush = (Brush)FindResource("Warning");
                textBlock.Foreground = (Brush)FindResource("Warning");
                break;
            default:
                border.Background = (Brush)FindResource("SurfaceSubtle");
                border.BorderBrush = (Brush)FindResource("BorderStrong");
                textBlock.Foreground = (Brush)FindResource("TextMuted");
                break;
        }
    }

    private void SetStepCircle(Border circle, TextBlock numberLabel, TextBlock captionLabel, RunStepState state)
    {
        Brush accentBrush;
        switch (state)
        {
            case RunStepState.Done:
                circle.Background = (Brush)FindResource("SuccessSoft");
                circle.BorderBrush = (Brush)FindResource("Success");
                accentBrush = (Brush)FindResource("Success");
                break;
            case RunStepState.Ready:
                circle.Background = (Brush)FindResource("InfoSoft");
                circle.BorderBrush = (Brush)FindResource("Info");
                accentBrush = (Brush)FindResource("Info");
                break;
            case RunStepState.NeedsAttention:
                circle.Background = (Brush)FindResource("WarningSoft");
                circle.BorderBrush = (Brush)FindResource("Warning");
                accentBrush = (Brush)FindResource("Warning");
                break;
            default:
                circle.Background = (Brush)FindResource("BgSecondary");
                circle.BorderBrush = (Brush)FindResource("BorderStrong");
                accentBrush = (Brush)FindResource("TextMuted");
                break;
        }

        numberLabel.Foreground = accentBrush;
        captionLabel.Foreground = accentBrush;
    }

    private void ApplyRunExecutionState(RunExecutionState state)
    {
        _viewModel.ProgressValue = state.ProgressValue;
        _viewModel.StatusText = state.StatusText;
        _viewModel.RunProgressDetailText = state.DetailText;
        _viewModel.ResultSummary = state.ResultSummary;
    }

    private void ApplyRunCompletionState(PatchRunResult result, RunCompletionState state)
    {
        _viewModel.StatusText = state.StatusText;
        _viewModel.RunProgressDetailText = state.DetailText;
        _viewModel.ResultSummary = state.ResultSummary;
        btnOpenOutputFolder.IsEnabled = state.EnableOpenOutputFolder;
        btnOpenOutputFolder.Visibility = state.EnableOpenOutputFolder ? Visibility.Visible : Visibility.Collapsed;
        btnCopyDiagnostics.IsEnabled = state.EnableCopyDiagnostics;
        btnCopyDiagnostics.Visibility = state.EnableCopyDiagnostics ? Visibility.Visible : Visibility.Collapsed;
        expRunWarnings.IsExpanded = state.ExpandDiagnostics;
        UpdateWarningChip(state.WarningCount);
        SetBanner(state.Banner);
    }

    private void ApplySqlConnectionFeedback(SqlConnectionTestFeedback feedback)
    {
        _viewModel.SqlTestResultText = feedback.Message;
        txtSqlTestResult.Foreground = feedback.Tone switch
        {
            SqlTestMessageTone.Success => (Brush)FindResource("Success"),
            SqlTestMessageTone.Error => (Brush)FindResource("Error"),
            _ => (Brush)FindResource("TextMuted")
        };

        if (feedback.Banner != null)
            SetBanner(feedback.Banner);
    }

}
