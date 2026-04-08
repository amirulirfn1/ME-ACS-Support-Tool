using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Diagnostics;
using System.IO;
using System.Runtime.CompilerServices;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;
using MediaColor = System.Windows.Media.Color;
using System.Windows.Input;
using Forms = System.Windows.Forms;
using MessageBox = System.Windows.MessageBox;
using MEACSSupportTool.Infrastructure;
using MEACSSupportTool.Models;
using MEACSSupportTool.Services;

namespace MEACSSupportTool;

public partial class MainWindow : Window, INotifyPropertyChanged
{
    private readonly LoggingService _loggingService;
    private readonly SupportEnvironmentService _environmentService;
    private readonly SupportActionRunner _actionRunner;
    private readonly ToolkitModuleService _moduleService;
    private readonly SupportToolSettingsService _settingsService;
    private readonly ISupportToolUpdateService _updateService;

    private SupportToolSettings _settings = new();
    private SupportToolUpdateCheckResult? _pendingUpdate;
    private SupportToolUpdateStatus? _lastUpdateStatus;
    private bool _isBusy;
    private bool _isRefreshing;
    private string _machineName = "Loading...";
    private string _currentUser = "Loading...";
    private string _adminStatus = "Checking...";
    private string _internetStatus = "Checking...";
    private string _rabbitMqStatus = "Checking...";
    private string _ssmsStatus = "Checking...";
    private string _sqlStatus = "Checking...";
    private string _databaseStatus = "Checking...";
    private string _lastRefreshText = "Never";
    private string _statusBanner = "Ready for the next support action.";
    private string _liveLogText = "Open the tool and refresh machine status before running a repair.";
    private string _sqlPatcherStatus = "Checking module...";
    private string _sqlPatcherBuildText = "Build date unavailable";
    private string _sqlPatcherLocation = "Toolkit module location not checked yet.";
    private string _sqlPatcherDetails = "Refresh status to inspect the imported SQL patcher module.";
    private string _appSubtitleText = SupportToolMetadata.Subtitle;
    private string _appBuildText = SupportToolMetadata.BuildLabel;
    private string _updateStatusText = "No update check has been run yet.";
    private string _updateFeedPathText = "Not configured";
    private string _lastUpdateCheckText = "Never";
    private string _updateSummaryText = "Update feed idle";
    private string? _updateSummaryOverride;
    private string _busyIndicatorText = "Working...";
    private bool _activityConsoleExpanded;
    private bool _bottomSectionExpanded;
    private bool _canLaunchSqlPatcher;
    private bool _canOpenSqlPatcherWorkspace;
    private bool _canApplyToolkitUpdate;
    private string? _currentLogFilePath;

    public MainWindow()
    {
        InitializeComponent();
        DataContext = this;

        _loggingService = new LoggingService();
        _environmentService = new SupportEnvironmentService();
        _moduleService = new ToolkitModuleService(AppContext.BaseDirectory);
        _settingsService = new SupportToolSettingsService(_loggingService.RootDirectory);
        _updateService = new SupportToolUpdateService();

        var sqlScriptPath = Path.Combine(AppContext.BaseDirectory, "Assets", "Sql", "Solve Client Lag Issues.sql");
        _actionRunner = new SupportActionRunner(_environmentService, sqlScriptPath);

        HistoryItems = new ObservableCollection<HistoryRecord>(_loggingService.LoadHistory());
        LogRootDirectory = _loggingService.RootDirectory;

        RefreshSqlPatcherModuleInfo();
        RefreshUpdateDisplay();
        Loaded += MainWindow_Loaded;
    }

    public event PropertyChangedEventHandler? PropertyChanged;

    public ObservableCollection<HistoryRecord> HistoryItems { get; }

    public string MachineName
    {
        get => _machineName;
        private set => SetField(ref _machineName, value);
    }

    public string CurrentUser
    {
        get => _currentUser;
        private set => SetField(ref _currentUser, value);
    }

    public string AdminStatus
    {
        get => _adminStatus;
        private set
        {
            SetField(ref _adminStatus, value);
            OnPropertyChanged(nameof(AdminWarningVisibility));
            OnPropertyChanged(nameof(AdminBadgeBorder));
            OnPropertyChanged(nameof(AdminBadgeBg));
        }
    }

    public string InternetStatus
    {
        get => _internetStatus;
        private set
        {
            SetField(ref _internetStatus, value);
            OnPropertyChanged(nameof(InternetBadgeBorder));
            OnPropertyChanged(nameof(InternetBadgeBg));
        }
    }

    public string RabbitMqStatus
    {
        get => _rabbitMqStatus;
        private set
        {
            SetField(ref _rabbitMqStatus, value);
            OnPropertyChanged(nameof(RabbitMqBadgeBorder));
            OnPropertyChanged(nameof(RabbitMqBadgeBg));
        }
    }

    public string SsmsStatus
    {
        get => _ssmsStatus;
        private set
        {
            SetField(ref _ssmsStatus, value);
            OnPropertyChanged(nameof(SsmsBadgeBorder));
            OnPropertyChanged(nameof(SsmsBadgeBg));
        }
    }

    public string SqlStatus
    {
        get => _sqlStatus;
        private set
        {
            SetField(ref _sqlStatus, value);
            OnPropertyChanged(nameof(SqlBadgeBorder));
            OnPropertyChanged(nameof(SqlBadgeBg));
        }
    }

    public string DatabaseStatus
    {
        get => _databaseStatus;
        private set
        {
            SetField(ref _databaseStatus, value);
            OnPropertyChanged(nameof(DatabaseBadgeBorder));
            OnPropertyChanged(nameof(DatabaseBadgeBg));
        }
    }

    public string LastRefreshText
    {
        get => _lastRefreshText;
        private set => SetField(ref _lastRefreshText, value);
    }

    public string StatusBanner
    {
        get => _statusBanner;
        private set => SetField(ref _statusBanner, value);
    }

    public string LiveLogText
    {
        get => _liveLogText;
        private set => SetField(ref _liveLogText, value);
    }

    public string SqlPatcherStatus
    {
        get => _sqlPatcherStatus;
        private set => SetField(ref _sqlPatcherStatus, value);
    }

    public string SqlPatcherBuildText
    {
        get => _sqlPatcherBuildText;
        private set => SetField(ref _sqlPatcherBuildText, value);
    }

    public string SqlPatcherLocation
    {
        get => _sqlPatcherLocation;
        private set => SetField(ref _sqlPatcherLocation, value);
    }

    public string SqlPatcherDetails
    {
        get => _sqlPatcherDetails;
        private set => SetField(ref _sqlPatcherDetails, value);
    }

    public string AppBuildText
    {
        get => _appBuildText;
        private set => SetField(ref _appBuildText, value);
    }

    public string AppSubtitleText
    {
        get => _appSubtitleText;
        private set => SetField(ref _appSubtitleText, value);
    }

    public string UpdateStatusText
    {
        get => _updateStatusText;
        private set => SetField(ref _updateStatusText, value);
    }

    public string UpdateFeedPathText
    {
        get => _updateFeedPathText;
        private set => SetField(ref _updateFeedPathText, value);
    }

    public string LastUpdateCheckText
    {
        get => _lastUpdateCheckText;
        private set => SetField(ref _lastUpdateCheckText, value);
    }

    public string UpdateSummaryText
    {
        get => _updateSummaryText;
        private set => SetField(ref _updateSummaryText, value);
    }

    public string BusyIndicatorText
    {
        get => _busyIndicatorText;
        private set => SetField(ref _busyIndicatorText, value);
    }

    public bool ActivityConsoleExpanded
    {
        get => _activityConsoleExpanded;
        private set
        {
            SetField(ref _activityConsoleExpanded, value);
            OnPropertyChanged(nameof(ActivityConsoleVisibility));
        }
    }

    public bool BottomSectionExpanded
    {
        get => _bottomSectionExpanded;
        set => SetField(ref _bottomSectionExpanded, value);
    }

    public string ThemeToggleLabel => ThemeService.IsDark ? "Light Mode" : "Dark Mode";

    public string LogRootDirectory { get; }

    public bool IsNotBusy => !_isBusy;

    public bool IsBusy => _isBusy;

    public bool CanOpenCurrentLog => !string.IsNullOrWhiteSpace(_currentLogFilePath) && File.Exists(_currentLogFilePath);

    public Visibility AdminWarningVisibility =>
        _adminStatus.Contains("Not") ? Visibility.Visible : Visibility.Collapsed;

    public Visibility ActivityConsoleVisibility =>
        _activityConsoleExpanded ? Visibility.Visible : Visibility.Collapsed;

    public Visibility ApplyUpdateVisibility =>
        _canApplyToolkitUpdate ? Visibility.Visible : Visibility.Collapsed;

    public bool IsNotRefreshing => !_isRefreshing;

    public bool IsRefreshing => _isRefreshing;

    public Visibility BusyIndicatorVisibility =>
        (_isBusy || _isRefreshing) ? Visibility.Visible : Visibility.Collapsed;

    // ── Status badge color coding ──────────────────────────────────────────

    private static readonly SolidColorBrush BrushGoodBorder = new(MediaColor.FromRgb(0x1F, 0x9A, 0x63));
    private static readonly SolidColorBrush BrushGoodBg     = new(MediaColor.FromRgb(0xDD, 0xF3, 0xE6));
    private static readonly SolidColorBrush BrushBadBorder  = new(MediaColor.FromRgb(0xCC, 0x3D, 0x3D));
    private static readonly SolidColorBrush BrushBadBg      = new(MediaColor.FromRgb(0xF7, 0xDE, 0xDE));
    private static readonly SolidColorBrush BrushWarnBorder = new(MediaColor.FromRgb(0xB5, 0x7A, 0x16));
    private static readonly SolidColorBrush BrushWarnBg     = new(MediaColor.FromRgb(0xF8, 0xEB, 0xCF));
    private static readonly SolidColorBrush BrushNeutralBorder = new(MediaColor.FromRgb(0xAF, 0xC0, 0xD8));
    private static readonly SolidColorBrush BrushNeutralBg     = new(MediaColor.FromRgb(0xE9, 0xEF, 0xF7));

    private static (SolidColorBrush border, SolidColorBrush bg) StatusBrushPair(string status)
    {
        if (status.Contains("Checking") || status.Contains("Loading"))
            return (BrushNeutralBorder, BrushNeutralBg);
        if (status.StartsWith("Not ") || status.StartsWith("not ") ||
            status.StartsWith("Offline") || status.Contains("not detected") ||
            status.Contains("not found") || status.Contains("not installed"))
            return (BrushBadBorder, BrushBadBg);
        if (status.Contains("but stopped") || status.Contains("blocked"))
            return (BrushWarnBorder, BrushWarnBg);
        return (BrushGoodBorder, BrushGoodBg);
    }

    public SolidColorBrush AdminBadgeBorder   => StatusBrushPair(_adminStatus).border;
    public SolidColorBrush AdminBadgeBg       => StatusBrushPair(_adminStatus).bg;
    public SolidColorBrush InternetBadgeBorder => StatusBrushPair(_internetStatus).border;
    public SolidColorBrush InternetBadgeBg     => StatusBrushPair(_internetStatus).bg;
    public SolidColorBrush RabbitMqBadgeBorder => StatusBrushPair(_rabbitMqStatus).border;
    public SolidColorBrush RabbitMqBadgeBg     => StatusBrushPair(_rabbitMqStatus).bg;
    public SolidColorBrush SqlBadgeBorder      => StatusBrushPair(_sqlStatus).border;
    public SolidColorBrush SqlBadgeBg          => StatusBrushPair(_sqlStatus).bg;
    public SolidColorBrush DatabaseBadgeBorder => StatusBrushPair(_databaseStatus).border;
    public SolidColorBrush DatabaseBadgeBg     => StatusBrushPair(_databaseStatus).bg;
    public SolidColorBrush SsmsBadgeBorder     => StatusBrushPair(_ssmsStatus).border;
    public SolidColorBrush SsmsBadgeBg         => StatusBrushPair(_ssmsStatus).bg;

    public bool CanLaunchSqlPatcher
    {
        get => _canLaunchSqlPatcher;
        private set => SetField(ref _canLaunchSqlPatcher, value);
    }

    public bool CanOpenSqlPatcherWorkspace
    {
        get => _canOpenSqlPatcherWorkspace;
        private set => SetField(ref _canOpenSqlPatcherWorkspace, value);
    }

    public bool CanApplyToolkitUpdate
    {
        get => _canApplyToolkitUpdate;
        private set
        {
            SetField(ref _canApplyToolkitUpdate, value);
            OnPropertyChanged(nameof(ApplyUpdateVisibility));
        }
    }

    private async void MainWindow_Loaded(object sender, RoutedEventArgs e)
    {
        try
        {
            _settings = await _settingsService.LoadAsync();
            ThemeService.Apply(_settings.IsDarkTheme);
            OnPropertyChanged(nameof(ThemeToggleLabel));
            RefreshUpdateDisplay();
            await RefreshStatusAsync();

            if (!string.IsNullOrWhiteSpace(GetEffectiveUpdateFeedPath()) && ShouldCheckUpdatesOnStartup())
            {
                await CheckForToolkitUpdatesAsync(showAlreadyUpToDateBanner: false);
            }
        }
        catch (Exception ex)
        {
            StatusBanner = $"Startup checks failed: {ex.Message}";
        }
    }

    private async void RefreshStatusButton_Click(object sender, RoutedEventArgs e)
    {
        await RefreshStatusAsync();
    }

    private async void CheckForToolkitUpdatesButton_Click(object sender, RoutedEventArgs e)
    {
        await CheckForToolkitUpdatesAsync(showAlreadyUpToDateBanner: true);
    }

    private async void ApplyToolkitUpdateButton_Click(object sender, RoutedEventArgs e)
    {
        if (_pendingUpdate is null || !_pendingUpdate.CanApplyNow)
        {
            return;
        }

        var confirmation = MessageBox.Show(
            _pendingUpdate.Message,
            "Apply Toolkit Update",
            MessageBoxButton.YesNo,
            MessageBoxImage.Question);

        if (confirmation != MessageBoxResult.Yes)
        {
            return;
        }

        SetBusy(true);
        try
        {
            StatusBanner = "Applying toolkit update...";
            BusyIndicatorText = "Applying toolkit update...";
            await _updateService.ApplyPendingUpdateAndRestartAsync(_pendingUpdate.InstallerUrl!, _pendingUpdate.InstallerSha256);
        }
        catch (Exception ex)
        {
            StatusBanner = $"Toolkit update failed: {ex.Message}";
            UpdateStatusText = ex.Message;
            MessageBox.Show(ex.Message, "Apply Toolkit Update", MessageBoxButton.OK, MessageBoxImage.Error);
        }
        finally
        {
            SetBusy(false);
        }
    }

    private async void ConfigureUpdateFeedButton_Click(object sender, RoutedEventArgs e)
    {
        using var dialog = new Forms.FolderBrowserDialog
        {
            Description = "Choose the ME ACS Support Tool update feed folder",
            ShowNewFolderButton = false
        };

        if (!string.IsNullOrWhiteSpace(_settings.AppUpdateFeedPath) && Directory.Exists(_settings.AppUpdateFeedPath))
        {
            dialog.InitialDirectory = _settings.AppUpdateFeedPath;
        }

        if (dialog.ShowDialog() != Forms.DialogResult.OK || string.IsNullOrWhiteSpace(dialog.SelectedPath))
        {
            return;
        }

        _settings.AppUpdateFeedPath = dialog.SelectedPath;
        await _settingsService.SaveAsync(_settings);
        RefreshUpdateDisplay();
        StatusBanner = "Toolkit update feed path saved. Checking for updates now...";
        await CheckForToolkitUpdatesAsync(showAlreadyUpToDateBanner: true);
    }

    private async void SetUpdateFeedUrlButton_Click(object sender, RoutedEventArgs e)
    {
        var currentValue = LooksLikeWebUrl(_settings.AppUpdateFeedPath)
            ? _settings.AppUpdateFeedPath!
            : "http://192.168.0.10:39000";

        var feedUrl = PromptForUpdateFeedUrl(currentValue);
        if (string.IsNullOrWhiteSpace(feedUrl))
        {
            return;
        }

        if (!Uri.TryCreate(feedUrl.Trim(), UriKind.Absolute, out var uri) ||
            (uri.Scheme != Uri.UriSchemeHttp && uri.Scheme != Uri.UriSchemeHttps))
        {
            MessageBox.Show(
                "Enter a full HTTP or HTTPS feed URL, for example http://192.168.0.10:39000",
                "Set Feed URL",
                MessageBoxButton.OK,
                MessageBoxImage.Information);
            return;
        }

        _settings.AppUpdateFeedPath = feedUrl.Trim().TrimEnd('/');
        await _settingsService.SaveAsync(_settings);
        RefreshUpdateDisplay();
        StatusBanner = "Toolkit update feed URL saved. Checking for updates now...";
        await CheckForToolkitUpdatesAsync(showAlreadyUpToDateBanner: true);
    }

    private async void ClearUpdateFeedButton_Click(object sender, RoutedEventArgs e)
    {
        _settings.AppUpdateFeedPath = null;
        _settings.LastUpdateCheckAt = null;
        _pendingUpdate = null;
        _lastUpdateStatus = null;
        _updateSummaryOverride = null;
        await _settingsService.SaveAsync(_settings);
        RefreshUpdateDisplay();
        var resolvedFeed = ResolveUpdateFeedPath();
        StatusBanner = resolvedFeed.Path is null
            ? "Toolkit update feed path cleared."
            : $"Saved feed cleared. Active feed now comes from {resolvedFeed.Source}.";
    }

    private async void RunRabbitMqRepairButton_Click(object sender, RoutedEventArgs e)
    {
        var confirmation = MessageBox.Show(
            "RabbitMQ Repair will uninstall and reinstall RabbitMQ and Erlang on this PC.\n\nDo you want to continue?",
            "Confirm RabbitMQ Repair",
            MessageBoxButton.YesNo,
            MessageBoxImage.Warning);

        if (confirmation != MessageBoxResult.Yes)
        {
            return;
        }

        await RunActionAsync("rabbitmq-repair", "RabbitMQ Repair", _actionRunner.RunRabbitMqRepairAsync);
    }

    private async void RunSolveClientLagButton_Click(object sender, RoutedEventArgs e)
    {
        await RunActionAsync("solve-client-lag", "Solve Client Lag", _actionRunner.RunSolveClientLagAsync);
    }

    private async void RunInstallSsmsButton_Click(object sender, RoutedEventArgs e)
    {
        var confirmation = MessageBox.Show(
            "Install SSMS will download the full SQL Server Management Studio installer and open it on this PC.\n\nDo you want to continue?",
            "Confirm Install SSMS",
            MessageBoxButton.YesNo,
            MessageBoxImage.Question);

        if (confirmation != MessageBoxResult.Yes)
        {
            return;
        }

        await RunActionAsync("install-ssms", "Install SSMS", _actionRunner.RunInstallSsmsAsync);
    }

    private async void RunCreateSupportUserButton_Click(object sender, RoutedEventArgs e)
    {
        var confirmation = MessageBox.Show(
            "Create Local User will create or update the local 'magetegra' account, add it to Administrators, and set the password to never expire.\n\nDo you want to continue?",
            "Confirm Create Local User",
            MessageBoxButton.YesNo,
            MessageBoxImage.Warning);

        if (confirmation != MessageBoxResult.Yes)
        {
            return;
        }

        await RunActionAsync("create-local-user", "Create Local User", _actionRunner.RunEnsureSupportUserAsync);
    }

    private void LaunchSqlPatcherButton_Click(object sender, RoutedEventArgs e)
    {
        var moduleInfo = _moduleService.GetSqlPatcherInfo();
        RefreshSqlPatcherModuleInfo(moduleInfo);

        if (!moduleInfo.CanLaunch)
        {
            MessageBox.Show(
                "The SQL patcher source has been imported into the toolkit, but no launchable executable was found yet.\n\nBuild or package the toolkit first, then launch again.",
                "SQL Patcher",
                MessageBoxButton.OK,
                MessageBoxImage.Information);
            return;
        }

        try
        {
            _moduleService.LaunchSqlPatcher(moduleInfo);
            StatusBanner = "Launching SQL Patcher in a separate window.";
        }
        catch (Exception ex)
        {
            StatusBanner = $"SQL Patcher: {ex.Message}";
            MessageBox.Show(ex.Message, "SQL Patcher", MessageBoxButton.OK, MessageBoxImage.Error);
        }
    }

    private void OpenSqlPatcherWorkspaceButton_Click(object sender, RoutedEventArgs e)
    {
        var moduleInfo = _moduleService.GetSqlPatcherInfo();
        RefreshSqlPatcherModuleInfo(moduleInfo);

        if (!moduleInfo.CanOpenWorkspace)
        {
            MessageBox.Show(
                "The SQL patcher module folder could not be found in the toolkit workspace.",
                "Open Module Folder",
                MessageBoxButton.OK,
                MessageBoxImage.Information);
            return;
        }

        try
        {
            _moduleService.OpenModuleWorkspace(moduleInfo);
        }
        catch (Exception ex)
        {
            MessageBox.Show(ex.Message, "Open Module Folder", MessageBoxButton.OK, MessageBoxImage.Error);
        }
    }

    private void OpenLogsFolderButton_Click(object sender, RoutedEventArgs e)
    {
        TryOpenPath(_loggingService.LogsDirectory, "Open Logs Folder");
    }

    private async void ToggleThemeButton_Click(object sender, RoutedEventArgs e)
    {
        _settings.IsDarkTheme = !_settings.IsDarkTheme;
        ThemeService.Apply(_settings.IsDarkTheme);
        OnPropertyChanged(nameof(ThemeToggleLabel));
        await _settingsService.SaveAsync(_settings);
    }

    private void OpenCurrentLogButton_Click(object sender, RoutedEventArgs e)
    {
        if (string.IsNullOrWhiteSpace(_currentLogFilePath) || !File.Exists(_currentLogFilePath))
        {
            MessageBox.Show("There is no current log file to open yet.", "Open Current Log", MessageBoxButton.OK, MessageBoxImage.Information);
            return;
        }

        TryOpenPath(_currentLogFilePath, "Open Current Log");
    }

    private async Task RefreshStatusAsync(bool updateStatusBanner = true)
    {
        SetRefreshing(true);
        BusyIndicatorText = "Refreshing machine checks...";

        if (updateStatusBanner)
        {
            StatusBanner = "Refreshing local machine checks...";
        }

        try
        {
            var snapshot = await _environmentService.GetSnapshotAsync();
            MachineName = snapshot.MachineName;
            CurrentUser = snapshot.CurrentUser;
            AdminStatus = snapshot.IsAdministrator ? "Ready" : "Not running as Administrator";
            InternetStatus = snapshot.HasInternetAccess ? "Online" : "Offline or blocked";
            RabbitMqStatus = snapshot.RabbitMqInstalled
                ? (snapshot.RabbitMqRunning ? "Installed and running" : "Installed but stopped")
                : "Not installed";
            SsmsStatus = snapshot.SsmsInstalled ? "Installed" : "Not installed";
            SqlStatus = snapshot.SqlReachable
                ? $"Connected ({snapshot.SqlDataSource})"
                : "Local SQL not detected";
            DatabaseStatus = snapshot.MagEtegraDatabaseExists
                ? "magetegra is present"
                : "magetegra not found";
            LastRefreshText = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss");
            if (updateStatusBanner)
            {
                StatusBanner = BuildRecommendedStatusBanner(snapshot);
            }
        }
        catch (Exception ex)
        {
            StatusBanner = $"Refresh failed: {ex.Message}";
        }
        finally
        {
            RefreshSqlPatcherModuleInfo();
            SetRefreshing(false);
        }
    }

    private async Task CheckForToolkitUpdatesAsync(bool showAlreadyUpToDateBanner)
    {
        SetRefreshing(true);
        BusyIndicatorText = "Checking toolkit updates...";
        try
        {
            var feedPath = GetEffectiveUpdateFeedPath();
            var result = await _updateService.CheckForUpdatesAsync(feedPath);
            _pendingUpdate = result.IsUpdateAvailable ? result : null;
            _lastUpdateStatus = result.Status;
            _updateSummaryOverride = null;
            _settings.LastUpdateCheckAt = DateTime.Now;
            await _settingsService.SaveAsync(_settings);
            RefreshUpdateDisplay(result);

            if (result.Status == SupportToolUpdateStatus.UpdateAvailable)
            {
                StatusBanner = "A toolkit update is ready to apply.";
            }
            else if (showAlreadyUpToDateBanner || result.Status == SupportToolUpdateStatus.NotConfigured)
            {
                StatusBanner = result.Message;
            }
        }
        catch (Exception ex)
        {
            _pendingUpdate = null;
            _lastUpdateStatus = null;
            _updateSummaryOverride = "Update check failed";
            UpdateStatusText = ex.Message;
            UpdateSummaryText = "Update check failed";
            StatusBanner = $"Toolkit update check failed: {ex.Message}";
        }
        finally
        {
            RefreshUpdateDisplay();
            SetRefreshing(false);
        }
    }

    private async Task RunActionAsync(string actionId, string actionName, Func<RunLogSession, Task<RunResult>> runner)
    {
        SetBusy(true);
        StatusBanner = $"Running {actionName}...";
        BusyIndicatorText = $"Running {actionName}...";
        LiveLogText = string.Empty;
        ActivityConsoleExpanded = true;
        BottomSectionExpanded = true;

        var startedAt = DateTime.Now;
        RunLogSession? session = null;
        RunOutcome finalOutcome = RunOutcome.Failed;
        string finalSummary = "Action did not complete.";
        var shouldRefreshAfterRun = false;
        try
        {
            session = _loggingService.CreateSession(actionId, actionName);
            _currentLogFilePath = session.LogFilePath;
            OnPropertyChanged(nameof(CanOpenCurrentLog));

            session.LineWritten += AppendLiveLogLine;

            await session.WriteAsync($"Machine: {Environment.MachineName}");
            await session.WriteAsync($"User: {Environment.UserName}");
            var result = await runner(session);
            await session.WriteAsync($"Finished with outcome: {result.Outcome}");
            await session.WriteAsync(result.Summary);
            finalOutcome = result.Outcome;
            finalSummary = result.Summary;
            shouldRefreshAfterRun = true;

            BusyIndicatorText = $"{actionName} finished. Refreshing machine checks...";
            await RefreshStatusAsync(updateStatusBanner: false);
            StatusBanner = $"{actionName}: {finalSummary}";

            if (finalOutcome == RunOutcome.Failed)
            {
                MessageBox.Show(finalSummary, actionName, MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }
        catch (Exception ex)
        {
            finalOutcome = RunOutcome.Failed;
            finalSummary = ex.Message;
            StatusBanner = $"{actionName}: {finalSummary}";
            shouldRefreshAfterRun = true;

            if (session is not null)
            {
                try
                {
                    await session.WriteAsync($"Unhandled error: {ex}");
                }
                catch
                {
                    // Keep the UI usable even if logging also fails.
                }
            }

            try
            {
                BusyIndicatorText = $"{actionName} failed. Refreshing machine checks...";
                await RefreshStatusAsync(updateStatusBanner: false);
            }
            catch
            {
                // Preserve the original action error if status refresh also fails.
            }

            MessageBox.Show(finalSummary, actionName, MessageBoxButton.OK, MessageBoxImage.Error);
        }
        finally
        {
            if (session is not null)
            {
                var history = new HistoryRecord
                {
                    RunId = session.RunId,
                    ActionId = actionId,
                    ActionName = actionName,
                    MachineName = Environment.MachineName,
                    UserName = Environment.UserName,
                    StartedAt = startedAt,
                    EndedAt = DateTime.Now,
                    Outcome = finalOutcome,
                    Summary = finalSummary,
                    LogFilePath = session.LogFilePath
                };

                try
                {
                    await _loggingService.SaveHistoryAsync(history);
                    HistoryItems.Insert(0, history);
                    while (HistoryItems.Count > 20)
                    {
                        HistoryItems.RemoveAt(HistoryItems.Count - 1);
                    }
                }
                catch
                {
                    StatusBanner = shouldRefreshAfterRun
                        ? StatusBanner
                        : $"{actionName}: finished, but run history could not be saved.";
                }
            }

            if (session is not null)
            {
                await session.DisposeAsync();
            }

            SetBusy(false);
        }
    }

    private void TryOpenPath(string path, string title)
    {
        try
        {
            Process.Start(new ProcessStartInfo
            {
                FileName = path,
                UseShellExecute = true
            });
        }
        catch (Exception ex)
        {
            MessageBox.Show(ex.Message, title, MessageBoxButton.OK, MessageBoxImage.Error);
        }
    }

    private void HistoryGrid_MouseDoubleClick(object sender, MouseButtonEventArgs e)
    {
        if (sender is not DataGrid grid || grid.SelectedItem is not HistoryRecord record)
        {
            return;
        }

        if (!File.Exists(record.LogFilePath))
        {
            MessageBox.Show("The selected run log could not be found.", "Open Run Log", MessageBoxButton.OK, MessageBoxImage.Information);
            return;
        }

        TryOpenPath(record.LogFilePath, "Open Run Log");
    }

    private void SetBusy(bool isBusy)
    {
        _isBusy = isBusy;
        if (!isBusy && !_isRefreshing)
        {
            BusyIndicatorText = "Ready";
        }
        OnPropertyChanged(nameof(IsBusy));
        OnPropertyChanged(nameof(IsNotBusy));
        OnPropertyChanged(nameof(BusyIndicatorVisibility));
    }

    private void SetRefreshing(bool refreshing)
    {
        _isRefreshing = refreshing;
        if (!refreshing && !_isBusy)
        {
            BusyIndicatorText = "Ready";
        }
        OnPropertyChanged(nameof(IsRefreshing));
        OnPropertyChanged(nameof(IsNotRefreshing));
        OnPropertyChanged(nameof(BusyIndicatorVisibility));
    }

    private void RefreshSqlPatcherModuleInfo()
    {
        RefreshSqlPatcherModuleInfo(_moduleService.GetSqlPatcherInfo());
    }

    private void RefreshSqlPatcherModuleInfo(ToolkitModuleInfo moduleInfo)
    {
        SqlPatcherStatus = moduleInfo.StatusText;
        SqlPatcherBuildText = moduleInfo.BuildText ?? "Build date unavailable";
        SqlPatcherLocation = moduleInfo.LocationText;
        SqlPatcherDetails = moduleInfo.DetailText;
        CanLaunchSqlPatcher = moduleInfo.CanLaunch;
        CanOpenSqlPatcherWorkspace = moduleInfo.CanOpenWorkspace;
    }

    private void RefreshUpdateDisplay(SupportToolUpdateCheckResult? latestResult = null)
    {
        AppBuildText = SupportToolMetadata.BuildLabel;
        AppSubtitleText = SupportToolMetadata.Subtitle;
        var resolvedFeed = ResolveUpdateFeedPath();
        UpdateFeedPathText = resolvedFeed.Path is null
            ? "Not configured"
            : $"{resolvedFeed.Path} ({resolvedFeed.Source})";
        LastUpdateCheckText = _settings.LastUpdateCheckAt?.ToString("yyyy-MM-dd HH:mm:ss") ?? "Never";

        if (latestResult is not null)
        {
            UpdateStatusText = latestResult.Message;
        }
        else if (_pendingUpdate is not null)
        {
            UpdateStatusText = _pendingUpdate.Message;
        }

        UpdateSummaryText = _updateSummaryOverride
            ?? (_pendingUpdate?.IsUpdateAvailable == true
                ? "Update ready"
                : resolvedFeed.Path is null
                    ? "Feed not set"
                    : _lastUpdateStatus == SupportToolUpdateStatus.NoUpdateAvailable
                        ? "Up to date"
                        : _settings.LastUpdateCheckAt.HasValue
                            ? "Updates checked"
                            : "Feed configured");

        CanApplyToolkitUpdate = _pendingUpdate?.CanApplyNow == true;
    }

    private string? GetEffectiveUpdateFeedPath()
        => ResolveUpdateFeedPath().Path;

    private (string? Path, string Source) ResolveUpdateFeedPath()
    {
        if (!string.IsNullOrWhiteSpace(_settings.AppUpdateFeedPath))
        {
            return (_settings.AppUpdateFeedPath, "saved feed");
        }

        var envPath = Environment.GetEnvironmentVariable("ME_ACS_SUPPORT_TOOL_UPDATE_FEED");
        if (!string.IsNullOrWhiteSpace(envPath))
        {
            return (envPath, "environment variable");
        }

        var toolkitRoot = FindToolkitRoot();
        if (!string.IsNullOrWhiteSpace(toolkitRoot))
        {
            var localFeed = Path.Combine(toolkitRoot, "feed", "support-tool");
            if (Directory.Exists(localFeed))
            {
                return (localFeed, "workspace default");
            }
        }

        return (null, "not configured");
    }

    private static bool LooksLikeWebUrl(string? value)
    {
        if (string.IsNullOrWhiteSpace(value))
        {
            return false;
        }

        return Uri.TryCreate(value.Trim(), UriKind.Absolute, out var uri) &&
               (uri.Scheme == Uri.UriSchemeHttp || uri.Scheme == Uri.UriSchemeHttps);
    }

    private string? PromptForUpdateFeedUrl(string initialValue)
    {
        using var form = new Forms.Form();
        using var descriptionLabel = new Forms.Label();
        using var urlTextBox = new Forms.TextBox();
        using var okButton = new Forms.Button();
        using var cancelButton = new Forms.Button();

        form.Text = "Set Feed URL";
        form.StartPosition = Forms.FormStartPosition.CenterParent;
        form.FormBorderStyle = Forms.FormBorderStyle.FixedDialog;
        form.MinimizeBox = false;
        form.MaximizeBox = false;
        form.ShowInTaskbar = false;
        form.ClientSize = new System.Drawing.Size(520, 150);

        descriptionLabel.AutoSize = false;
        descriptionLabel.Text = "Enter the full update feed URL from your update host PC, for example http://192.168.0.10:39000";
        descriptionLabel.SetBounds(12, 12, 496, 38);

        urlTextBox.SetBounds(12, 62, 496, 26);
        urlTextBox.Text = initialValue;
        urlTextBox.Anchor = Forms.AnchorStyles.Top | Forms.AnchorStyles.Left | Forms.AnchorStyles.Right;

        okButton.Text = "Save";
        okButton.DialogResult = Forms.DialogResult.OK;
        okButton.SetBounds(352, 104, 75, 28);

        cancelButton.Text = "Cancel";
        cancelButton.DialogResult = Forms.DialogResult.Cancel;
        cancelButton.SetBounds(433, 104, 75, 28);

        form.Controls.Add(descriptionLabel);
        form.Controls.Add(urlTextBox);
        form.Controls.Add(okButton);
        form.Controls.Add(cancelButton);
        form.AcceptButton = okButton;
        form.CancelButton = cancelButton;

        var ownerHandle = new System.Windows.Interop.WindowInteropHelper(this).Handle;
        var owner = new Forms.NativeWindow();
        try
        {
            owner.AssignHandle(ownerHandle);
            return form.ShowDialog(owner) == Forms.DialogResult.OK
                ? urlTextBox.Text
                : null;
        }
        finally
        {
            owner.ReleaseHandle();
        }
    }

    private bool ShouldCheckUpdatesOnStartup()
    {
        return !_settings.LastUpdateCheckAt.HasValue ||
               DateTime.Now - _settings.LastUpdateCheckAt.Value > TimeSpan.FromHours(4);
    }

    private string? FindToolkitRoot()
    {
        var current = new DirectoryInfo(AppContext.BaseDirectory);
        while (current is not null)
        {
            var solutionPath = Path.Combine(current.FullName, "ME_ACS_Toolkit.sln");
            var appProjectPath = Path.Combine(current.FullName, "MEACSSupportTool", "MEACSSupportTool.csproj");
            if (File.Exists(solutionPath) || File.Exists(appProjectPath))
            {
                return current.FullName;
            }

            current = current.Parent;
        }

        return null;
    }

    private void AppendLiveLogLine(string line)
    {
        Dispatcher.Invoke(() =>
        {
            const int maxLogCharacters = 24000;
            var nextValue = string.Concat(LiveLogText, line, Environment.NewLine);
            if (nextValue.Length > maxLogCharacters)
            {
                nextValue = nextValue[^maxLogCharacters..];
            }

            LiveLogText = nextValue;

            var progressStatus = TryExtractProgressStatus(line);
            if (!string.IsNullOrWhiteSpace(progressStatus) && (_isBusy || _isRefreshing))
            {
                BusyIndicatorText = progressStatus;
            }
        });
    }

    private static string? TryExtractProgressStatus(string line)
    {
        const string marker = "Download progress - ";
        var markerIndex = line.IndexOf(marker, StringComparison.Ordinal);
        if (markerIndex < 0)
        {
            return null;
        }

        return line[(markerIndex + marker.Length)..].Trim();
    }

    private void SetField<T>(ref T field, T value, [CallerMemberName] string? propertyName = null)
    {
        if (EqualityComparer<T>.Default.Equals(field, value))
        {
            return;
        }

        field = value;
        OnPropertyChanged(propertyName);
    }

    private void OnPropertyChanged([CallerMemberName] string? propertyName = null)
    {
        PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
    }

    private static string BuildRecommendedStatusBanner(SupportEnvironmentSnapshot snapshot)
    {
        if (!snapshot.IsAdministrator)
        {
            return "Administrator access is required for repair tasks. Reopen the tool and approve the UAC prompt if needed.";
        }

        if (!snapshot.HasInternetAccess)
        {
            return "Internet looks blocked. RabbitMQ Repair and SSMS install both need downloads before they can continue.";
        }

        if (!snapshot.RabbitMqInstalled)
        {
            return "RabbitMQ is not installed on this PC. Use RabbitMQ Repair if this machine should be running MagServer.";
        }

        if (snapshot.RabbitMqInstalled && !snapshot.RabbitMqRunning)
        {
            return "RabbitMQ is installed but stopped. Use RabbitMQ Repair if a restart or PC rename broke the service.";
        }

        if (!snapshot.SqlReachable)
        {
            return "Local SQL Server was not detected. Open SQL Patcher if you need to work against a different server or remote database.";
        }

        if (!snapshot.MagEtegraDatabaseExists)
        {
            return "Local SQL is reachable, but the magetegra database is missing on this machine.";
        }

        if (!snapshot.SsmsInstalled)
        {
            return "Machine checks look good. Install SSMS if you still need direct database tools on this PC.";
        }

        return "Machine checks look healthy. Use Open SQL Patcher for patch workflows or run a repair only when needed.";
    }
}
