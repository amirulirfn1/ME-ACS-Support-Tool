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
    private async void BtnToggleTheme_Click(object sender, RoutedEventArgs e)
    {
        _settings.IsDarkTheme = !_settings.IsDarkTheme;
        ThemeService.Apply(_settings.IsDarkTheme);
        btnToggleTheme.Content = _settings.IsDarkTheme ? "Light Mode" : "Dark Mode";
        await PersistSettingsAsync();
    }

    private void BtnAdminTools_Click(object sender, RoutedEventArgs e)
    {
        if (_versionService == null)
        {
            _dialogs.ShowWarning("Patches are still loading. Try again in a moment.", "Admin Tools");
            return;
        }

        if (_adminWindow is { IsLoaded: true })
        {
            _adminWindow.Activate();
            _adminWindow.Focus();
            return;
        }

        _adminWindow = new AdminWindow(
            _versionService,
            RefreshMainAfterAdminMutationAsync,
            getCurrentPatchesFolder: GetCurrentPatchesFolder,
            setPatchesFolderAsync: SetPatchesFolderFromAdminAsync,
            resetPatchesFolderAsync: ResetPatchesFolderFromAdminAsync,
            persistSettingsAsync: PersistSettingsAsync,
            getVersionService: () => _versionService)
        {
            Owner = this
        };
        _adminWindow.Closed += (_, _) => _adminWindow = null;
        _adminWindow.Show();
    }

    private async Task SetPatchesFolderFromAdminAsync(string folder)
    {
        await SetPatchesFolderAsync(folder, closeAdminWindow: false);
    }

    private async Task<string> ResetPatchesFolderFromAdminAsync()
    {
        var writableFolder = _patchStorageService.GetDefaultPatchesFolder();
        await _patchStorageService.ResetToBundledAsync(writableFolder, _bundledPatchesFolder);
        _settings.LastImportedPatchPack = null;
        await SetPatchesFolderAsync(writableFolder, closeAdminWindow: false);
        return writableFolder;
    }

    private void CmbSourcePath_SelectionChanged(object sender, SelectionChangedEventArgs e)
    {
        if (_isLoadingUi)
            return;

        var selected = (cmbSourcePath.SelectedItem as string) ?? cmbSourcePath.Text;
        if (!string.IsNullOrWhiteSpace(selected))
            _viewModel.RememberRecentBackup(selected);

        RefreshRunSummary();
    }

    private void BtnBrowse_Click(object sender, RoutedEventArgs e)
    {
        var dialog = new OpenFileDialog
        {
            Filter = "Backup Files (*.bak)|*.bak|All Files (*.*)|*.*",
            Title = "Select source backup file"
        };

        if (dialog.ShowDialog() != true)
            return;

        cmbSourcePath.Text = dialog.FileName;
        _viewModel.RememberRecentBackup(dialog.FileName);
        RefreshRunSummary();
    }

    private void CmbFromVersion_SelectionChanged(object sender, SelectionChangedEventArgs e)
    {
        if (_isLoadingUi)
            return;

        RefreshTargetVersions();
        RefreshRunSummary();
    }

    private void CmbToVersion_SelectionChanged(object sender, SelectionChangedEventArgs e)
    {
        if (_isLoadingUi)
            return;

        UpdateUpgradePathText();
        RefreshRunSummary();
    }

    private void BtnPatchToLatest_Click(object sender, RoutedEventArgs e)
    {
        if (_viewModel.TargetVersions.Count == 0)
            return;

        cmbToVersion.SelectedIndex = _viewModel.TargetVersions.Count - 1;
    }

    private void AuthMode_Checked(object sender, RoutedEventArgs e)
    {
        if (!_isUiInitialized)
            return;

        UpdateAuthModeUi();
        RefreshRunSummary();
    }

    private void FocusPrimaryInput()
    {
        if (!string.IsNullOrWhiteSpace(cmbSourcePath.Text))
        {
            cmbFromVersion.Focus();
            return;
        }

        cmbSourcePath.Focus();
    }

    private void FocusFirstIncompleteStep()
    {
        var sourcePath = (cmbSourcePath.Text ?? "").Trim();
        if (string.IsNullOrWhiteSpace(sourcePath) || !File.Exists(sourcePath))
        {
            cmbSourcePath.Focus();
            return;
        }

        if (GetSelectedVersionId(cmbFromVersion) == null || GetSelectedVersionId(cmbToVersion) == null)
        {
            if (GetSelectedVersionId(cmbFromVersion) == null)
                cmbFromVersion.Focus();
            else
                cmbToVersion.Focus();
            return;
        }

        if (string.IsNullOrWhiteSpace(cmbSqlServer.Text))
        {
            cmbSqlServer.Focus();
            return;
        }

        btnTestSql.Focus();
    }

    private async void BtnTestSql_Click(object sender, RoutedEventArgs e)
    {
        if (!_runOrchestrator.IsReady)
            return;

        var settings = BuildSqlConnectionSettings();
        if (string.IsNullOrWhiteSpace(settings.Server))
        {
            ApplySqlConnectionFeedback(_sqlConnectionTestCoordinator.CreateMissingServerFeedback());
            return;
        }

        if (!LocalSqlValidator.IsLocalServer(settings.Server))
        {
            ApplySqlConnectionFeedback(_sqlConnectionTestCoordinator.CreateNonLocalServerFeedback());
            return;
        }

        btnTestSql.IsEnabled = false;
        ApplySqlConnectionFeedback(_sqlConnectionTestCoordinator.CreateTestingFeedback());

        try
        {
            var ok = await _runOrchestrator.TestConnectionAsync(settings);
            if (ok)
            {
                ApplySqlConnectionFeedback(_sqlConnectionTestCoordinator.RegisterSuccess(settings));
            }
            else
            {
                ApplySqlConnectionFeedback(_sqlConnectionTestCoordinator.RegisterFailure(
                    "Failed to connect.",
                    "SQL connection failed. Check server/auth settings."));
            }
        }
        catch (Exception ex)
        {
            ApplySqlConnectionFeedback(_sqlConnectionTestCoordinator.RegisterFailure(
                ex.Message,
                "SQL connection test failed."));
        }
        finally
        {
            btnTestSql.IsEnabled = true;
            RefreshRunSummary();
            UpdateGuidanceUi();
        }
    }

    private void BtnBrowseTempFolder_Click(object sender, RoutedEventArgs e)
    {
        var dialog = new OpenFolderDialog
        {
            Title = "Select temp folder",
            InitialDirectory = string.IsNullOrWhiteSpace(txtTempFolder.Text) ? Environment.CurrentDirectory : txtTempFolder.Text.Trim(),
            Multiselect = false
        };

        if (dialog.ShowDialog() != true)
            return;

        txtTempFolder.Text = dialog.FolderName;
        RefreshRunSummary();
    }

    private void BtnResetTempFolder_Click(object sender, RoutedEventArgs e)
    {
        txtTempFolder.Text = _patchStorageService.GetDefaultTempFolder();
        RefreshRunSummary();
    }

    private async void BtnChangePatchesFolder_Click(object sender, RoutedEventArgs e)
    {
        var dialog = new OpenFolderDialog
        {
            Title = "Select patches folder",
            InitialDirectory = GetCurrentPatchesFolder(),
            Multiselect = false
        };

        if (dialog.ShowDialog() != true)
            return;

        await SetPatchesFolderAsync(dialog.FolderName);
        await PersistSettingsAsync();
        SetBanner(NotificationLevel.Success, "Patches folder updated.");
    }

    private void BtnOpenPatchesFolder_Click(object sender, RoutedEventArgs e)
    {
        var folder = GetCurrentPatchesFolder();
        if (!Directory.Exists(folder))
        {
            _dialogs.ShowWarning("Patches folder does not exist.", "Open Folder");
            return;
        }

        Process.Start(new ProcessStartInfo
        {
            FileName = folder,
            UseShellExecute = true
        });
    }

    private async void BtnResetPatchesFolder_Click(object sender, RoutedEventArgs e)
    {
        var writableFolder = _patchStorageService.GetDefaultPatchesFolder();
        await _patchStorageService.ResetToBundledAsync(writableFolder, _bundledPatchesFolder);
        _settings.LastImportedPatchPack = null;
        await SetPatchesFolderAsync(writableFolder);
        await PersistSettingsAsync();
        SetBanner(NotificationLevel.Success, "Patch library reset to the managed app-data folder.");
    }

    private async void BtnImportPatchPack_Click(object sender, RoutedEventArgs e)
    {
        if (_patchImportCoordinator == null)
            return;

        var dialog = new OpenFileDialog
        {
            Filter = "Patch pack (*.zip)|*.zip|All files (*.*)|*.*",
            Title = "Select patch pack"
        };

        if (dialog.ShowDialog() != true)
            return;

        btnImportPatchPack.IsEnabled = false;
        try
        {
            _sessionLog.WriteLine($"[{DateTime.Now:HH:mm:ss}] Importing patch pack: {dialog.FileName}");
            var result = await _patchImportCoordinator.ImportAsync(new PatchImportRequest
            {
                ZipPath = dialog.FileName,
                TargetPatchesFolder = GetCurrentPatchesFolder()
            });

            _settings.LastImportedPatchPack = result.PackLabel;

            await SetPatchesFolderAsync(GetCurrentPatchesFolder());
            await PersistSettingsAsync();

            var archiveSuffix = string.IsNullOrWhiteSpace(result.ArchivedPackPath)
                ? string.Empty
                : $" Archive: {result.ArchivedPackPath}";
            SetBanner(NotificationLevel.Success, $"Patch pack imported. Backup: {result.BackupFolder}{archiveSuffix}");
            _sessionLog.WriteLine($"[{DateTime.Now:HH:mm:ss}] Patch pack imported successfully. Backup: {result.BackupFolder}{archiveSuffix}");
        }
        catch (Exception ex)
        {
            _sessionLog.WriteLine($"[{DateTime.Now:HH:mm:ss}] Patch pack import failed: {ex.Message}");
            _dialogs.ShowError(ex.Message, "Import Failed");
            SetBanner(NotificationLevel.Error, "Patch pack import failed.");
        }
        finally
        {
            btnImportPatchPack.IsEnabled = true;
            RefreshRunSummary();
        }
    }

    private void BtnRetryFromValidation_Click(object sender, RoutedEventArgs e)
    {
        var validation = ValidateCurrentRequest(requirePassword: true);
        if (validation.IsValid)
        {
            ClearValidationIssues();
            SetBanner(NotificationLevel.Success, "Validation passed. Ready to start patch.");
        }
        else
        {
            SetValidationIssues(validation.Issues);
            SetBanner(NotificationLevel.Error, "Validation failed. Fix highlighted items.");
        }
    }

    private void BtnCopyDiagnostics_Click(object sender, RoutedEventArgs e)
    {
        var text = BuildDiagnosticsText();
        Clipboard.SetText(text);
        SetBanner(NotificationLevel.Info, "Diagnostics copied to clipboard.");
    }

    private void BtnOpenOutputFolder_Click(object sender, RoutedEventArgs e)
    {
        OpenOutputFolder(_lastOutputPath, showErrors: true);
    }

    private void BtnCopyPatchPlan_Click(object sender, RoutedEventArgs e)
    {
        var text = BuildPatchPlanText();
        Clipboard.SetText(text);
        SetBanner(NotificationLevel.Info, "Patch plan copied to clipboard.");
    }

    private void BtnCancel_Click(object sender, RoutedEventArgs e)
    {
        if (_runCancellation == null)
            return;

        _runCancellation.Cancel();
        SetBanner(NotificationLevel.Info, "Cancelling patch run...");
    }

    private async void BtnPatch_Click(object sender, RoutedEventArgs e)
    {
        if (!_runOrchestrator.IsReady)
            return;

        var validation = ValidateCurrentRequest(requirePassword: true);
        if (!validation.IsValid)
        {
            SetValidationIssues(validation.Issues);
            SetBanner(NotificationLevel.Error, "Validation failed. Fix highlighted items.");
            FocusFirstIncompleteStep();
            return;
        }

        ClearValidationIssues();

        if (!string.IsNullOrWhiteSpace(validation.Request.SourceBakPath) && !File.Exists(validation.Request.SourceBakPath))
        {
            _dialogs.ShowWarning("Source backup file does not exist.", "Validation");
            SetBanner(NotificationLevel.Error, "Source backup file does not exist.");
            FocusFirstIncompleteStep();
            return;
        }

        var planPreview = BuildPatchPlanText();
        if (!_dialogs.Confirm(
                $"{planPreview}\n\nStart patch now?",
                "Confirm Patch Run"))
            return;

        _viewModel.RememberRecentBackup(validation.Request.SourceBakPath);
        _lastOutputPath = validation.Request.OutputBakPath;

        ClearLogBuffers();
        _logFlushTimer.Stop();
        _viewModel.ClearRunWarnings();
        _runWarningDetails.Clear();
        UpdateWarningChip(0);
        expRunWarnings.IsExpanded = false;

        _viewModel.StatusText = "Starting...";
        btnOpenOutputFolder.IsEnabled = false;
        btnCopyDiagnostics.IsEnabled = false;
        ApplyRunExecutionState(_runExecutionPresenter.BuildStartingState(validation.Request));

        ApplyRunUiLock(isRunning: true);
        SetBanner(NotificationLevel.Info, "Patch run started.");

        _runCancellation = new CancellationTokenSource();

        try
        {
            var progress = new Progress<PatchRunProgress>(p =>
            {
                ApplyRunExecutionState(_runExecutionPresenter.BuildProgressState(p));
            });

            var logProgress = new Progress<string>(AppendLogLine);
            var result = await _runOrchestrator.RunAsync(validation.Request, progress, logProgress, _runCancellation.Token);

            _lastOutputPath = result.OutputPath;

            RefreshWarningList(result.Warnings);

            var completionState = _runExecutionPresenter.BuildCompletionState(result, HasRetainedLogs());
            ApplyRunCompletionState(result, completionState);
            if (result.Success)
            {
                _viewModel.ProgressValue = 100;
                OpenOutputFolder(result.OutputPath, showErrors: false);
            }
        }
        catch (Exception ex)
        {
            ApplyRunCompletionState(
                new PatchRunResult { Summary = ex.Message },
                _runExecutionPresenter.BuildUnexpectedFailureState(ex));
        }
        finally
        {
            _runCancellation.Dispose();
            _runCancellation = null;
            ApplyRunUiLock(isRunning: false);
            RefreshRunSummary();
            await PersistSettingsAsync();
        }
    }
}
