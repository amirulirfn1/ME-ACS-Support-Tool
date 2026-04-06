using MagDbPatcher.Workflows;
using MagDbPatcher.ViewModels;

namespace MagDbPatcher.Infrastructure;

public sealed class RunExecutionPresenter
{
    public RunExecutionState BuildInitialState()
        => new(0, "Ready", "Phase: Idle", string.Empty);

    public RunExecutionState BuildStartingState(PatchRunRequest request)
        => new(
            0,
            "Starting patch run...",
            $"Phase: Preparing{Environment.NewLine}Target: {request.FromVersionId} -> {request.ToVersionId}{Environment.NewLine}Warnings: 0",
            string.Empty);

    public RunExecutionState BuildProgressState(PatchRunProgress progress)
    {
        var phase = DeterminePhase(progress.Message);
        var scriptDetail = progress.TotalScripts > 0
            ? $"Scripts: {Math.Max(progress.CurrentScript, 0)}/{progress.TotalScripts}"
            : "Scripts: n/a";

        return new RunExecutionState(
            progress.Percent,
            progress.Message,
            $"Phase: {phase}{Environment.NewLine}{scriptDetail}{Environment.NewLine}Warnings: {progress.WarningCount}",
            string.Empty);
    }

    public RunCompletionState BuildCompletionState(PatchRunResult result, bool hasRetainedLogs)
    {
        var diagnosticsHint = BuildDiagnosticsHint();

        if (result.Success)
        {
            var warningSummary = result.WarningThresholdExceeded
                ? $"Warnings: {result.WarningCount} exceeded threshold {result.WarningThreshold}."
                : $"Warnings: {result.WarningCount} of threshold {result.WarningThreshold}.";
            var banner = result.WarningThresholdExceeded
                ? new NotificationState(NotificationLevel.Info, $"Patch completed with warnings above threshold ({result.WarningCount}/{result.WarningThreshold}).", true)
                : result.WarningCount > 0
                    ? new NotificationState(NotificationLevel.Info, "Patch completed with warnings.", true)
                    : new NotificationState(NotificationLevel.Success, "Patch completed successfully.");

            return new RunCompletionState(
                "Completed",
                $"Phase: Completed{Environment.NewLine}Scripts finished{Environment.NewLine}Warnings: {result.WarningCount}",
                $"Output: {result.OutputPath}{Environment.NewLine}{warningSummary}{Environment.NewLine}{diagnosticsHint}",
                banner,
                EnableOpenOutputFolder: !string.IsNullOrWhiteSpace(result.OutputPath),
                EnableCopyDiagnostics: result.WarningCount > 0 || hasRetainedLogs,
                WarningCount: result.WarningCount,
                ExpandDiagnostics: result.WarningCount > 0);
        }

        if (result.Cancelled)
        {
            return new RunCompletionState(
                "Cancelled",
                $"Phase: Cancelled{Environment.NewLine}Warnings captured: {result.WarningCount}",
                $"Patch run was cancelled before completion.{Environment.NewLine}{diagnosticsHint}",
                new NotificationState(NotificationLevel.Info, "Patch run cancelled."),
                EnableOpenOutputFolder: false,
                EnableCopyDiagnostics: hasRetainedLogs || result.WarningCount > 0,
                WarningCount: result.WarningCount,
                ExpandDiagnostics: result.WarningCount > 0);
        }

        return new RunCompletionState(
            "Failed",
            $"Phase: Failed{Environment.NewLine}Warnings captured: {result.WarningCount}",
            $"Patch run failed.{Environment.NewLine}Error: {result.Summary}{Environment.NewLine}{diagnosticsHint}",
            new NotificationState(NotificationLevel.Error, "Patch failed. Review diagnostics."),
            EnableOpenOutputFolder: false,
            EnableCopyDiagnostics: true,
            WarningCount: result.WarningCount,
            ExpandDiagnostics: true);
    }

    public RunCompletionState BuildUnexpectedFailureState(Exception ex)
    {
        return new RunCompletionState(
            "Failed",
            "Phase: Failed",
            $"Patch run failed unexpectedly.{Environment.NewLine}Error: {ex.Message}{Environment.NewLine}{BuildDiagnosticsHint()}",
            new NotificationState(NotificationLevel.Error, "Patch failed unexpectedly."),
            EnableOpenOutputFolder: false,
            EnableCopyDiagnostics: true,
            WarningCount: 0,
            ExpandDiagnostics: true);
    }

    private static string DeterminePhase(string message)
    {
        if (string.IsNullOrWhiteSpace(message))
            return "Idle";

        if (message.Contains("copying backup", StringComparison.OrdinalIgnoreCase) ||
            message.Contains("calculating upgrade path", StringComparison.OrdinalIgnoreCase) ||
            message.Contains("starting", StringComparison.OrdinalIgnoreCase))
        {
            return "Preparing";
        }

        if (message.Contains("restoring", StringComparison.OrdinalIgnoreCase))
            return "Restore";

        if (message.Contains("running:", StringComparison.OrdinalIgnoreCase) ||
            message.Contains("upgrading from", StringComparison.OrdinalIgnoreCase) ||
            message.Contains("executing:", StringComparison.OrdinalIgnoreCase) ||
            message.Contains("completed:", StringComparison.OrdinalIgnoreCase))
        {
            return "Script execution";
        }

        if (message.Contains("creating output backup", StringComparison.OrdinalIgnoreCase) ||
            message.Contains("copying to output location", StringComparison.OrdinalIgnoreCase) ||
            message.Contains("backup", StringComparison.OrdinalIgnoreCase))
        {
            return "Backup";
        }

        if (message.Contains("cleaning up", StringComparison.OrdinalIgnoreCase) ||
            message.Contains("cleanup", StringComparison.OrdinalIgnoreCase))
        {
            return "Cleanup";
        }

        if (message.Contains("completed", StringComparison.OrdinalIgnoreCase))
            return "Completed";

        return "Running";
    }

    private static string BuildDiagnosticsHint()
        => $"Use 'Copy Diagnostics' for the full runtime log. Background diagnostics are stored at {DiagnosticsLog.CurrentPath}.";
}
