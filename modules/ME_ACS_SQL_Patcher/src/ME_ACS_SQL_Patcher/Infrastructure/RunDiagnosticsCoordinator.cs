using MagDbPatcher.Services;
using MagDbPatcher.Models;
using MagDbPatcher.Workflows;

namespace MagDbPatcher.Infrastructure;

public sealed class RunDiagnosticsCoordinator
{
    public string BuildPatchPlan(IMainRunOrchestrator orchestrator, PatchRunRequest request)
        => orchestrator.BuildPatchPlan(request);

    public string BuildDiagnostics(
        IMainRunOrchestrator orchestrator,
        PatchRunRequest request,
        string status,
        string resultSummary,
        IEnumerable<SqlBatchWarning> runWarnings,
        IEnumerable<string> runtimeLogLines,
        IEnumerable<string>? nonFatalDiagnostics)
    {
        return orchestrator.BuildDiagnostics(
            status,
            resultSummary,
            runWarnings,
            runtimeLogLines,
            request,
            nonFatalDiagnostics);
    }
}
