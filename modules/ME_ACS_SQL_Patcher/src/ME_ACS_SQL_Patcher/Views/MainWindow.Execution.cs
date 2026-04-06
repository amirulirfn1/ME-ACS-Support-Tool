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

public partial class MainWindow
{
    private string BuildOutputBakPath(string sourceBakPath, string toVersionId)
        => _requestBuilder.BuildOutputBakPath(sourceBakPath, toVersionId);

    private void SyncExecutionSettingsFromUi()
    {
        _settings.PatchTempFolder = string.IsNullOrWhiteSpace(txtTempFolder.Text)
            ? _patchStorageService.GetDefaultTempFolder()
            : txtTempFolder.Text.Trim();
        _settings.WarningThreshold = ParseWarningThreshold();
        _settings.PatchErrorMode = GetSelectedPatchErrorMode();
    }

    private PatchErrorMode GetSelectedPatchErrorMode()
    {
        return cmbErrorMode.SelectedValue is PatchErrorMode mode
            ? mode
            : PatchErrorMode.WarnAndContinue;
    }

    private int ParseWarningThreshold()
    {
        return int.TryParse(txtWarningThreshold.Text, NumberStyles.Integer, CultureInfo.InvariantCulture, out var threshold) && threshold > 0
            ? threshold
            : 10;
    }

    private void UpdateAuthModeUi()
    {
        if (pnlSqlLogin == null || rbAuthSql == null)
            return;

        pnlSqlLogin.Visibility = rbAuthSql.IsChecked == true ? Visibility.Visible : Visibility.Collapsed;
    }

    private void EditableComboTextChanged(object sender, TextChangedEventArgs e)
    {
        if (_isLoadingUi)
            return;

        if (sender == cmbSourcePath || e.OriginalSource is TextBox tb && tb.TemplatedParent == cmbSourcePath)
            UpdateSourcePlaceholder();

        RefreshRunSummary();
    }

    private void UpdateSourcePlaceholder()
    {
        txtSourcePlaceholder.Visibility = string.IsNullOrEmpty(cmbSourcePath.Text)
            ? Visibility.Visible
            : Visibility.Collapsed;
    }

    private void AdvancedRunSettingTextChanged(object sender, TextChangedEventArgs e)
    {
        if (_isLoadingUi)
            return;

        RefreshRunSummary();
    }

    private void AdvancedRunSettingSelectionChanged(object sender, SelectionChangedEventArgs e)
    {
        if (_isLoadingUi)
            return;

        RefreshRunSummary();
    }

    private void AdvancedRunSettingPasswordChanged(object sender, RoutedEventArgs e)
    {
        if (_isLoadingUi)
            return;

        RefreshRunSummary();
    }

    private void SetBanner(NotificationLevel level, string message, bool warningBanner = false)
        => SetBanner(new NotificationState(level, message, warningBanner));

    private void SetBanner(NotificationState state)
    {
        _viewModel.NotificationMessage = state.Message;
        _viewModel.NotificationLevel = state.Level;

        if (state.WarningBanner)
            bdStatusBanner.Style = (Style)FindResource("StatusBannerWarning");
        else
            bdStatusBanner.Style = state.Level switch
            {
                NotificationLevel.Success => (Style)FindResource("StatusBannerSuccess"),
                NotificationLevel.Error   => (Style)FindResource("StatusBannerError"),
                _                         => (Style)FindResource("StatusBannerInfo")
            };

        bdStatusBanner.Opacity = 0;
        bdStatusBanner.Visibility = Visibility.Visible;
        bdStatusBanner.BeginAnimation(UIElement.OpacityProperty,
            new DoubleAnimation(0, 1, new Duration(TimeSpan.FromMilliseconds(180))));
    }

    private void SetValidationIssues(IEnumerable<ValidationIssue> issues)
    {
        _viewModel.SetValidationIssues(issues);
        btnRetryFromValidation.IsEnabled = _viewModel.ValidationIssues.Count > 0;
        btnRetryFromValidation.Visibility = _viewModel.ValidationIssues.Count > 0 ? Visibility.Visible : Visibility.Collapsed;
        lstValidationIssues.Visibility = _viewModel.ValidationIssues.Count > 0 ? Visibility.Visible : Visibility.Collapsed;
    }

    private void ClearValidationIssues()
    {
        _viewModel.ClearValidation();
        btnRetryFromValidation.IsEnabled = false;
        btnRetryFromValidation.Visibility = Visibility.Collapsed;
        lstValidationIssues.Visibility = Visibility.Collapsed;
    }

    private void UpdateWarningChip(int count)
    {
        if (count > 0)
        {
            txtWarningChip.Text = count.ToString(CultureInfo.InvariantCulture);
            bdWarningChip.Visibility = Visibility.Visible;
        }
        else
        {
            bdWarningChip.Visibility = Visibility.Collapsed;
        }
    }

    private SqlConnectionSettings BuildSqlConnectionSettings()
    {
        var sqlLogin = rbAuthSql.IsChecked == true;
        return new SqlConnectionSettings
        {
            Server = (cmbSqlServer.Text ?? "").Trim(),
            AuthMode = sqlLogin ? SqlAuthMode.SqlLogin : SqlAuthMode.Windows,
            Username = (txtSqlUsername.Text ?? "").Trim(),
            Password = sqlLogin ? pwdSqlPassword.Password : null
        };
    }

    private PatchRunRequest BuildRunRequest()
    {
        SyncExecutionSettingsFromUi();
        var sourceBakPath = (cmbSourcePath.Text ?? "").Trim();
        var fromVersion = GetSelectedVersionId(cmbFromVersion) ?? "";
        var toVersion = GetSelectedVersionId(cmbToVersion) ?? "";
        var connectionSettings = BuildSqlConnectionSettings();
        return _requestBuilder.Build(sourceBakPath, fromVersion, toVersion, _settings, connectionSettings);
    }

    private (bool IsValid, PatchRunRequest Request, List<ValidationIssue> Issues) ValidateCurrentRequest(bool requirePassword)
    {
        var request = BuildRunRequest();
        var issues = _runOrchestrator.Validate(request, requirePassword).ToList();
        return (issues.Count == 0, request, issues);
    }

    private void AppendLogLine(string line)
    {
        var stamped = $"[{DateTime.Now:HH:mm:ss}] {line}";
        _pendingLogLines.Enqueue(stamped);
        _sessionLog.WriteLine(stamped);
        if (!_logFlushTimer.IsEnabled)
            _logFlushTimer.Start();
    }

    private void FlushPendingLogLines()
    {
        if (_pendingLogLines.Count == 0)
        {
            _logFlushTimer.Stop();
            return;
        }

        while (_pendingLogLines.Count > 0)
        {
            var line = _pendingLogLines.Dequeue();
            EnqueueWithCap(_retainedLogLines, line, MaxRetainedLogLines);
            EnqueueWithCap(_visibleLogLines, line, MaxVisibleLogLines);

            var entry = new ViewModels.LogEntry(line, DetectLogSeverity(line));
            _viewModel.LogEntries.Add(entry);
            while (_viewModel.LogEntries.Count > MaxVisibleLogLines)
                _viewModel.LogEntries.RemoveAt(0);
        }

        txtLogEmpty.Visibility = Visibility.Collapsed;
        logScrollViewer.ScrollToBottom();
    }

    private static ViewModels.LogSeverity DetectLogSeverity(string line)
    {
        // Lines are stamped "[HH:mm:ss] ..." — skip the 11-char timestamp prefix
        var content = line.Length > 11 ? line.AsSpan(11).TrimStart() : line.AsSpan();
        if (content.StartsWith("[ERROR]", StringComparison.OrdinalIgnoreCase) ||
            content.StartsWith("ERROR:", StringComparison.OrdinalIgnoreCase))
            return ViewModels.LogSeverity.Error;
        if (content.StartsWith("[WARN]", StringComparison.OrdinalIgnoreCase) ||
            content.StartsWith("[WARNING]", StringComparison.OrdinalIgnoreCase) ||
            content.StartsWith("WARN:", StringComparison.OrdinalIgnoreCase))
            return ViewModels.LogSeverity.Warning;
        return ViewModels.LogSeverity.Info;
    }

    private static void EnqueueWithCap(Queue<string> queue, string line, int maxCount)
    {
        queue.Enqueue(line);
        while (queue.Count > maxCount)
            queue.Dequeue();
    }

    private bool HasRetainedLogs() => _retainedLogLines.Count > 0;

    private void ClearLogBuffers()
    {
        _pendingLogLines.Clear();
        _visibleLogLines.Clear();
        _retainedLogLines.Clear();
        _viewModel.LogEntries.Clear();
        txtLogEmpty.Visibility = Visibility.Visible;
    }

    private void ApplyRunUiLock(bool isRunning)
    {
        var state = _runUiStateController.GetState(isRunning);
        btnPatch.IsEnabled = state.PatchEnabled;
        btnCancel.IsEnabled = state.CancelEnabled;
        btnBrowse.IsEnabled = state.BrowseEnabled;
        cmbSourcePath.IsEnabled = state.SourceSelectorEnabled;
        cmbFromVersion.IsEnabled = state.FromSelectorEnabled;
        cmbToVersion.IsEnabled = state.ToSelectorEnabled;
        btnPatchToLatest.IsEnabled = state.PatchToLatestEnabled;
        btnAdminTools.IsEnabled = state.AdminToolsEnabled;
        btnCopyPatchPlan.IsEnabled = state.CopyPatchPlanEnabled;
        btnImportPatchPack.IsEnabled = state.ImportPatchPackEnabled;
        cmbSqlServer.IsEnabled = state.SourceSelectorEnabled;
        btnTestSql.IsEnabled = state.BrowseEnabled;
        rbAuthWindows.IsEnabled = state.SourceSelectorEnabled;
        rbAuthSql.IsEnabled = state.SourceSelectorEnabled;
        txtSqlUsername.IsEnabled = state.SourceSelectorEnabled;
        pwdSqlPassword.IsEnabled = state.SourceSelectorEnabled;
        txtTempFolder.IsEnabled = state.SourceSelectorEnabled;
        btnBrowseTempFolder.IsEnabled = state.BrowseEnabled;
        btnResetTempFolder.IsEnabled = state.BrowseEnabled;
        cmbErrorMode.IsEnabled = state.SourceSelectorEnabled;
        txtWarningThreshold.IsEnabled = state.SourceSelectorEnabled;
        UpdateGuidanceUi();
    }

    private async Task PersistSettingsAsync()
    {
        SyncExecutionSettingsFromUi();
        _settings = _settingsBinder.BuildPersistedSettings(new SettingsPersistInput
        {
            Existing = _settings,
            PatchesFolder = txtPatchesFolder.Text.Trim(),
            LastSqlServer = (cmbSqlServer.Text ?? "").Trim(),
            LastOutputFolder = string.IsNullOrWhiteSpace(_lastOutputPath) ? _settings.LastOutputFolder : Path.GetDirectoryName(_lastOutputPath),
            RecentBackupFiles = _viewModel.RecentBackupFiles.ToList(),
            LastImportedPatchPack = _settings.LastImportedPatchPack,
            SqlAuthMode = rbAuthSql.IsChecked == true ? SqlAuthMode.SqlLogin : SqlAuthMode.Windows,
            SqlUsername = txtSqlUsername.Text.Trim()
        });

        await _settingsService.SaveAsync(_settings);
    }

    private async Task RefreshMainAfterAdminMutationAsync()
    {
        if (_versionService == null)
            return;

        await _versionService.LoadVersionsAsync();
        RefreshVersionSelectors(tryPreserveSelection: true);
        RefreshRunSummary();
    }

    private string BuildPatchPlanText()
    {
        var request = BuildRunRequest();
        return _runDiagnosticsCoordinator.BuildPatchPlan(_runOrchestrator, request);
    }

    private string BuildDiagnosticsText()
    {
        FlushPendingLogLines();
        return _runDiagnosticsCoordinator.BuildDiagnostics(
            _runOrchestrator,
            BuildRunRequest(),
            _viewModel.StatusText,
            _viewModel.ResultSummary,
            _runWarningDetails,
            _retainedLogLines,
            _versionService?.NonFatalDiagnostics);
    }

    private void RefreshWarningList(IReadOnlyList<SqlBatchWarning> warnings)
    {
        _viewModel.ClearRunWarnings();
        _runWarningDetails.Clear();

        foreach (var warning in warnings)
            _runWarningDetails.Add(warning);

        foreach (var item in _runWarningFormatter.BuildItems(warnings))
            _viewModel.RunWarnings.Add(item);
    }

    private void OpenOutputFolder(string outputPath, bool showErrors)
    {
        if (string.IsNullOrWhiteSpace(outputPath))
        {
            if (showErrors)
                _dialogs.ShowInfo("No output file available yet.", "Open Output");
            return;
        }

        try
        {
            if (File.Exists(outputPath))
            {
                Process.Start(new ProcessStartInfo
                {
                    FileName = "explorer.exe",
                    Arguments = $"/select,\"{outputPath}\"",
                    UseShellExecute = true
                });
                return;
            }

            var folder = Path.GetDirectoryName(outputPath);
            if (!string.IsNullOrWhiteSpace(folder) && Directory.Exists(folder))
            {
                Process.Start(new ProcessStartInfo
                {
                    FileName = folder,
                    UseShellExecute = true
                });
                return;
            }

            if (showErrors)
                _dialogs.ShowWarning("Output folder is not available.", "Open Output");
        }
        catch (Exception ex)
        {
            _sessionLog.WriteLine($"[{DateTime.Now:HH:mm:ss}] Failed to open output folder: {ex.Message}");
            if (showErrors)
                _dialogs.ShowWarning($"Could not open output folder: {ex.Message}", "Open Output");
        }
    }
}
