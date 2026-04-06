using MagDbPatcher.Models;
using MagDbPatcher.Services;
using MagDbPatcher.ViewModels;

namespace MagDbPatcher.Workflows;

public interface IMainRunOrchestrator
{
    bool IsReady { get; }
    void UpdateVersionService(IVersionService versionService);
    IReadOnlyList<ValidationIssue> Validate(PatchRunRequest request, bool requirePassword);
    Task<bool> TestConnectionAsync(SqlConnectionSettings settings);
    Task<PatchRunResult> RunAsync(
        PatchRunRequest request,
        IProgress<PatchRunProgress>? progress,
        IProgress<string>? logProgress,
        CancellationToken cancellationToken);
    string BuildPatchPlan(PatchRunRequest request);
    string BuildDiagnostics(
        string status,
        string resultSummary,
        IEnumerable<SqlBatchWarning> runWarnings,
        IEnumerable<string> runtimeLogLines,
        PatchRunRequest request,
        IEnumerable<string>? nonFatalDiagnostics);
}
