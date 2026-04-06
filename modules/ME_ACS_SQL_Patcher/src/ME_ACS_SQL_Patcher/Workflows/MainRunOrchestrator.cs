using MagDbPatcher.Infrastructure;
using MagDbPatcher.Models;
using MagDbPatcher.Services;
using MagDbPatcher.ViewModels;

namespace MagDbPatcher.Workflows;

public sealed class MainRunOrchestrator : IMainRunOrchestrator
{
    private readonly DiagnosticsComposer _diagnosticsComposer = new();
    private IVersionService? _versionService;
    private PatchRunCoordinator? _runCoordinator;

    public bool IsReady => _runCoordinator != null;

    public void UpdateVersionService(IVersionService versionService)
    {
        _versionService = versionService;
        _runCoordinator = new PatchRunCoordinator(versionService);
    }

    public IReadOnlyList<ValidationIssue> Validate(PatchRunRequest request, bool requirePassword)
    {
        if (_runCoordinator == null)
        {
            return new[]
            {
                new ValidationIssue
                {
                    Field = "Application",
                    Message = "Patching service is not initialized yet."
                }
            };
        }

        return _runCoordinator.Validate(request, requirePassword);
    }

    public Task<bool> TestConnectionAsync(SqlConnectionSettings settings)
    {
        if (_runCoordinator == null)
            throw new InvalidOperationException("Patching service is not initialized.");

        return _runCoordinator.TestConnectionAsync(settings);
    }

    public Task<PatchRunResult> RunAsync(
        PatchRunRequest request,
        IProgress<PatchRunProgress>? progress,
        IProgress<string>? logProgress,
        CancellationToken cancellationToken)
    {
        if (_runCoordinator == null)
            throw new InvalidOperationException("Patching service is not initialized.");

        return _runCoordinator.RunAsync(request, progress, logProgress, cancellationToken);
    }

    public string BuildPatchPlan(PatchRunRequest request)
        => _diagnosticsComposer.BuildPatchPlan(request, _versionService);

    public string BuildDiagnostics(
        string status,
        string resultSummary,
        IEnumerable<SqlBatchWarning> runWarnings,
        IEnumerable<string> runtimeLogLines,
        PatchRunRequest request,
        IEnumerable<string>? nonFatalDiagnostics)
    {
        return _diagnosticsComposer.BuildDiagnostics(
            status,
            resultSummary,
            runWarnings,
            string.Join(Environment.NewLine, runtimeLogLines),
            BuildPatchPlan(request),
            nonFatalDiagnostics);
    }
}
