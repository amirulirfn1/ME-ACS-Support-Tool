using MagDbPatcher.Models;
using MagDbPatcher.Services;
using MagDbPatcher.ViewModels;
using MagDbPatcher.Workflows;

namespace MagDbPatcher.Infrastructure;

public enum RunStepState
{
    Pending,
    Ready,
    Done,
    NeedsAttention
}

public enum SourceFileHintKind
{
    None,
    Success,
    Error
}

public enum SqlTestMessageTone
{
    Neutral,
    Success,
    Error
}

public sealed record StepGuidanceState(
    RunStepState Step1State,
    RunStepState Step2State,
    RunStepState Step3State,
    RunStepState Step4State,
    bool RunReady,
    string NextActionText,
    string PatchHintText)
{
    public static StepGuidanceState Initial { get; } = new(
        RunStepState.Pending,
        RunStepState.Pending,
        RunStepState.Pending,
        RunStepState.Pending,
        false,
        "Next: Select a source backup file.",
        "Complete Step 1 to continue.");
}

public sealed record RunSummaryState(
    string SourceFileHint,
    SourceFileHintKind SourceFileHintKind,
    string SourceText,
    string UpgradePathText,
    string ConnectionText,
    string PlanText,
    string OutputText,
    string SafeguardsText);

public sealed record RunSummaryInput(
    string SourceBakPath,
    string FromVersionId,
    string ToVersionId,
    string SqlServer,
    SqlAuthMode SqlAuthMode,
    bool SqlConnectionTestPassed,
    string TempFolder,
    PatchErrorMode ErrorMode,
    int WarningThreshold,
    string OutputBakPath,
    IVersionService? VersionService);

public sealed record SqlConnectionTestFeedback(
    bool Passed,
    string Message,
    SqlTestMessageTone Tone,
    NotificationState? Banner = null);

public sealed record RunExecutionState(
    int ProgressValue,
    string StatusText,
    string DetailText,
    string ResultSummary);

public sealed record RunCompletionState(
    string StatusText,
    string DetailText,
    string ResultSummary,
    NotificationState Banner,
    bool EnableOpenOutputFolder,
    bool EnableCopyDiagnostics,
    int WarningCount,
    bool ExpandDiagnostics);

public sealed record NotificationState(
    NotificationLevel Level,
    string Message,
    bool WarningBanner = false);
