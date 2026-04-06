using System.Collections.ObjectModel;
using MagDbPatcher.Infrastructure;
using MagDbPatcher.Models;
using MagDbPatcher.Services;

namespace MagDbPatcher.ViewModels;

public sealed class MainViewModel : BindableBase
{
    private PatchFlowState _flowState = PatchFlowState.SelectSource;
    private string _sourceBackupPath = "";
    private VersionInfo? _fromVersion;
    private VersionInfo? _toVersion;
    private string _upgradePath = "";
    private string _statusText = "Ready";
    private int _progressValue;
    private string _logText = "";
    private string _notificationMessage = "";
    private NotificationLevel _notificationLevel;
    private string _diagnosticsText = "";
    private string _resultSummary = "";
    private bool _canRetry;
    private string _patchVersionText = "";
    private string _appBuildText = AppMetadata.BuildLabel;
    private string _nextActionText = "Next: Select a source backup file.";
    private string _patchActionHint = "Complete Step 1 to continue.";
    private string _runSummarySource = "Select a source backup file to preview the run.";
    private string _runSummaryUpgradePath = "Select source and target versions to preview the upgrade path.";
    private string _runSummaryConnection = "Server: .\\MAGSQL";
    private string _runSummaryPlan = "Choose versions to calculate steps and script count.";
    private string _runSummaryOutput = "Select a source backup to resolve the output path.";
    private string _runSummarySafeguards = $"Temp: {AppRuntimePaths.CreateDefault().TempFolder}";
    private string _runProgressDetailText = "Phase: Idle";
    private string _sourceFileHintText = "";
    private SourceFileHintKind _sourceFileHintKind;
    private string _sqlTestResultText = "";
    private string _upgradePathText = "";

    private int _warningCount;

    public SqlConnectionViewModel Sql { get; } = new();
    public AdminToolsViewModel Admin { get; } = new();
    public ObservableCollection<string> RecentBackupFiles { get; } = new();
    public ObservableCollection<VersionInfo> SourceVersions { get; } = new();
    public ObservableCollection<VersionInfo> TargetVersions { get; } = new();
    public ObservableCollection<ValidationIssue> ValidationIssues { get; } = new();
    public ObservableCollection<DiagnosticWarningItem> RunWarnings { get; } = new();
    public ObservableCollection<LogEntry> LogEntries { get; } = new();

    public int WarningCount
    {
        get => _warningCount;
        set => SetProperty(ref _warningCount, value);
    }

    public void RememberRecentBackup(string sourceBakPath)
    {
        if (string.IsNullOrWhiteSpace(sourceBakPath))
            return;

        var normalized = sourceBakPath.Trim();
        var existing = RecentBackupFiles.FirstOrDefault(p =>
            string.Equals(p, normalized, StringComparison.OrdinalIgnoreCase));
        if (existing != null)
            RecentBackupFiles.Remove(existing);

        RecentBackupFiles.Insert(0, normalized);
        while (RecentBackupFiles.Count > 5)
            RecentBackupFiles.RemoveAt(RecentBackupFiles.Count - 1);
    }

    public void ClearRunWarnings()
    {
        RunWarnings.Clear();
        WarningCount = 0;
    }

    public PatchFlowState FlowState
    {
        get => _flowState;
        set => SetProperty(ref _flowState, value);
    }

    public string SourceBackupPath
    {
        get => _sourceBackupPath;
        set => SetProperty(ref _sourceBackupPath, value);
    }

    public VersionInfo? FromVersion
    {
        get => _fromVersion;
        set => SetProperty(ref _fromVersion, value);
    }

    public VersionInfo? ToVersion
    {
        get => _toVersion;
        set => SetProperty(ref _toVersion, value);
    }

    public string UpgradePath
    {
        get => _upgradePath;
        set => SetProperty(ref _upgradePath, value);
    }

    public string StatusText
    {
        get => _statusText;
        set => SetProperty(ref _statusText, value);
    }

    public int ProgressValue
    {
        get => _progressValue;
        set => SetProperty(ref _progressValue, value);
    }

    public string LogText
    {
        get => _logText;
        set => SetProperty(ref _logText, value);
    }

    public string NotificationMessage
    {
        get => _notificationMessage;
        set => SetProperty(ref _notificationMessage, value);
    }

    public NotificationLevel NotificationLevel
    {
        get => _notificationLevel;
        set => SetProperty(ref _notificationLevel, value);
    }

    public string DiagnosticsText
    {
        get => _diagnosticsText;
        set => SetProperty(ref _diagnosticsText, value);
    }

    public string ResultSummary
    {
        get => _resultSummary;
        set => SetProperty(ref _resultSummary, value);
    }

    public bool CanRetry
    {
        get => _canRetry;
        set => SetProperty(ref _canRetry, value);
    }

    public string PatchVersionText
    {
        get => _patchVersionText;
        set => SetProperty(ref _patchVersionText, value);
    }

    public string AppBuildText
    {
        get => _appBuildText;
        set => SetProperty(ref _appBuildText, value);
    }

    public string NextActionText
    {
        get => _nextActionText;
        set => SetProperty(ref _nextActionText, value);
    }

    public string PatchActionHint
    {
        get => _patchActionHint;
        set => SetProperty(ref _patchActionHint, value);
    }

    public string RunSummarySource
    {
        get => _runSummarySource;
        set => SetProperty(ref _runSummarySource, value);
    }

    public string RunSummaryUpgradePath
    {
        get => _runSummaryUpgradePath;
        set => SetProperty(ref _runSummaryUpgradePath, value);
    }

    public string RunSummaryConnection
    {
        get => _runSummaryConnection;
        set => SetProperty(ref _runSummaryConnection, value);
    }

    public string RunSummaryPlan
    {
        get => _runSummaryPlan;
        set => SetProperty(ref _runSummaryPlan, value);
    }

    public string RunSummaryOutput
    {
        get => _runSummaryOutput;
        set => SetProperty(ref _runSummaryOutput, value);
    }

    public string RunSummarySafeguards
    {
        get => _runSummarySafeguards;
        set => SetProperty(ref _runSummarySafeguards, value);
    }

    public string RunProgressDetailText
    {
        get => _runProgressDetailText;
        set => SetProperty(ref _runProgressDetailText, value);
    }

    public string SourceFileHintText
    {
        get => _sourceFileHintText;
        set => SetProperty(ref _sourceFileHintText, value);
    }

    public SourceFileHintKind SourceFileHintKind
    {
        get => _sourceFileHintKind;
        set => SetProperty(ref _sourceFileHintKind, value);
    }

    public string SqlTestResultText
    {
        get => _sqlTestResultText;
        set => SetProperty(ref _sqlTestResultText, value);
    }

    public string UpgradePathText
    {
        get => _upgradePathText;
        set => SetProperty(ref _upgradePathText, value);
    }

    public void Log(string message)
    {
        var timestamp = DateTime.Now.ToString("HH:mm:ss");
        LogText += $"[{timestamp}] {message}\n";
    }

    public void ClearValidation() => ValidationIssues.Clear();

    public void SetValidationIssues(IEnumerable<ValidationIssue> issues)
    {
        ValidationIssues.Clear();
        foreach (var issue in issues)
            ValidationIssues.Add(issue);
    }
}
