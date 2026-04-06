using System.IO;
using System.Text;
using MagDbPatcher.Models;
using MagDbPatcher.Services;
using MagDbPatcher.ViewModels;

namespace MagDbPatcher.Workflows;

public sealed class PatchRunCoordinator
{
    private readonly IVersionService _versionService;
    private readonly Func<SqlConnectionSettings, IProgress<string>?, IProgress<SqlBatchWarning>?, PatchExecutionOptions?, SqlServerService> _sqlFactory;

    public PatchRunCoordinator(
        IVersionService versionService,
        Func<SqlConnectionSettings, IProgress<string>?, IProgress<SqlBatchWarning>?, PatchExecutionOptions?, SqlServerService>? sqlFactory = null)
    {
        _versionService = versionService;
        _sqlFactory = sqlFactory ?? ((settings, progress, warnings, options) => new SqlServerService(settings, progress, warnings, options));
    }

    public IReadOnlyList<ValidationIssue> Validate(PatchRunRequest request, bool requirePassword)
    {
        var issues = new List<ValidationIssue>();

        if (string.IsNullOrWhiteSpace(request.SourceBakPath) || !File.Exists(request.SourceBakPath))
        {
            issues.Add(new ValidationIssue { Field = "Source Backup", Message = "Please select a valid source backup file." });
        }

        if (string.IsNullOrWhiteSpace(request.FromVersionId) || string.IsNullOrWhiteSpace(request.ToVersionId))
        {
            issues.Add(new ValidationIssue { Field = "Versions", Message = "Please select source and target versions." });
        }

        if (string.IsNullOrWhiteSpace(request.ConnectionSettings.Server))
        {
            issues.Add(new ValidationIssue { Field = "SQL Server", Message = "Please enter a SQL Server name." });
        }
        else if (!LocalSqlValidator.IsLocalServer(request.ConnectionSettings.Server))
        {
            issues.Add(new ValidationIssue
            {
                Field = "SQL Server",
                Message = "Only local SQL Server instances are allowed. Use .\\INSTANCE or (localdb)\\MSSQLLocalDB."
            });
        }

        if (request.ConnectionSettings.AuthMode == SqlAuthMode.SqlLogin)
        {
            if (string.IsNullOrWhiteSpace(request.ConnectionSettings.Username))
            {
                issues.Add(new ValidationIssue { Field = "SQL Username", Message = "Please enter a SQL username." });
            }

            if (requirePassword && string.IsNullOrWhiteSpace(request.ConnectionSettings.Password))
            {
                issues.Add(new ValidationIssue { Field = "SQL Password", Message = "Please enter a SQL password." });
            }
        }

        if (_versionService.LastValidationResult.HasErrors)
        {
            issues.Add(new ValidationIssue
            {
                Field = "Patch Configuration",
                Message = "Your patches configuration has errors. See logs for details."
            });
        }

        return issues;
    }

    public async Task<bool> TestConnectionAsync(SqlConnectionSettings settings)
    {
        var svc = _sqlFactory(settings, null, null, null);
        return await svc.TestConnectionAsync();
    }

    public async Task<PatchRunResult> RunAsync(
        PatchRunRequest request,
        IProgress<PatchRunProgress>? progress,
        IProgress<string>? logProgress,
        CancellationToken cancellationToken)
    {
        var warnings = new List<SqlBatchWarning>();
        var steps = _versionService.CalculateUpgradePath(request.FromVersionId, request.ToVersionId);
        var totalScripts = steps.Sum(s => s.Scripts.Count);
        var currentScript = 0;
        var currentPercent = 15;
        var warningThreshold = request.ExecutionOptions.WarningThreshold <= 0 ? 10 : request.ExecutionOptions.WarningThreshold;

        var sqlProgress = new Progress<string>(message =>
        {
            if (message.StartsWith("Running:", StringComparison.OrdinalIgnoreCase))
            {
                currentScript = Math.Min(currentScript + 1, totalScripts);
                currentPercent = 20 + (int)(currentScript * 60.0 / Math.Max(totalScripts, 1));
                progress?.Report(new PatchRunProgress
                {
                    Percent = currentPercent,
                    Message = $"{message} (Script {currentScript}/{totalScripts})",
                    FlowState = PatchFlowState.Run,
                    CurrentScript = currentScript,
                    TotalScripts = totalScripts,
                    WarningCount = warnings.Count
                });
            }
            else
            {
                currentPercent = currentScript > 0 ? 20 + (int)(currentScript * 60.0 / Math.Max(totalScripts, 1)) : 15;
                progress?.Report(new PatchRunProgress
                {
                    Percent = currentPercent,
                    Message = message,
                    FlowState = PatchFlowState.Run,
                    CurrentScript = currentScript,
                    TotalScripts = totalScripts,
                    WarningCount = warnings.Count
                });
            }

            logProgress?.Report(message);
        });

        var warningProgress = new CallbackProgress<SqlBatchWarning>(warning =>
        {
            warnings.Add(warning);
            progress?.Report(new PatchRunProgress
            {
                Percent = currentPercent,
                Message = $"Warning in {warning.ScriptName}: SQL {warning.ErrorNumber}",
                FlowState = PatchFlowState.Run,
                CurrentScript = currentScript,
                TotalScripts = totalScripts,
                WarningCount = warnings.Count
            });
        });

        var sqlService = _sqlFactory(request.ConnectionSettings, sqlProgress, warningProgress, request.ExecutionOptions);

        var patchProgress = new Progress<(int percent, string message)>(p =>
        {
            currentPercent = p.percent;
            progress?.Report(new PatchRunProgress
            {
                Percent = p.percent,
                Message = p.message,
                FlowState = PatchFlowState.Run,
                CurrentScript = currentScript,
                TotalScripts = totalScripts,
                WarningCount = warnings.Count
            });
            logProgress?.Report(p.message);
        });

        var patchService = new PatchService(sqlService, _versionService, patchProgress);
        var started = DateTime.UtcNow;

        try
        {
            var output = await patchService.PatchDatabaseAsync(
                request.SourceBakPath,
                request.FromVersionId,
                request.ToVersionId,
                request.OutputBakPath,
                request.TempFolder,
                cancellationToken);

            var duration = DateTime.UtcNow - started;
            var warningCount = warnings.Count;
            var warningMap = BuildWarningCounts(warnings);
            var warningThresholdExceeded = warningCount > warningThreshold;
            var summary = warningThresholdExceeded
                ? $"Completed in {duration:mm\\:ss}. Warnings: {warningCount} exceeded threshold {warningThreshold}. Output: {output}"
                : $"Completed in {duration:mm\\:ss}. Warnings: {warningCount}. Output: {output}";

            return new PatchRunResult
            {
                Success = true,
                OutputPath = output,
                WarningCount = warningCount,
                WarningThreshold = warningThreshold,
                WarningThresholdExceeded = warningThresholdExceeded,
                Summary = summary,
                Diagnostics = BuildDiagnostics(steps, warnings),
                Warnings = warnings.ToList(),
                WarningCountsBySqlError = warningMap
            };
        }
        catch (OperationCanceledException)
        {
            return new PatchRunResult
            {
                Cancelled = true,
                Summary = "Patch operation cancelled.",
                Diagnostics = BuildDiagnostics(steps, warnings),
                WarningCount = warnings.Count,
                WarningThreshold = warningThreshold,
                Warnings = warnings.ToList(),
                WarningCountsBySqlError = BuildWarningCounts(warnings)
            };
        }
        catch (Exception ex)
        {
            return new PatchRunResult
            {
                Success = false,
                Summary = ex.Message,
                Diagnostics = BuildDiagnostics(steps, warnings, ex),
                WarningCount = warnings.Count,
                WarningThreshold = warningThreshold,
                Warnings = warnings.ToList(),
                WarningCountsBySqlError = BuildWarningCounts(warnings)
            };
        }
    }

    private static IReadOnlyDictionary<int, int> BuildWarningCounts(IEnumerable<SqlBatchWarning> warnings) =>
        warnings
            .GroupBy(w => w.ErrorNumber)
            .ToDictionary(g => g.Key, g => g.Count());

    private static string BuildDiagnostics(IReadOnlyList<PatchStep> steps, List<SqlBatchWarning> warnings, Exception? ex = null)
    {
        var sb = new StringBuilder();

        sb.AppendLine("Path strategy: shortest-step BFS over strictly increasing version order.");
        sb.AppendLine($"Selected path: {BuildPathOverview(steps)}");

        if (ex != null)
        {
            sb.AppendLine($"Error: {ex.GetType().Name}: {ex.Message}");
            var inner = ex.InnerException;
            var depth = 0;
            while (inner != null && depth < 10)
            {
                sb.AppendLine($"Inner: {inner.GetType().Name}: {inner.Message}");
                inner = inner.InnerException;
                depth++;
            }
        }

        if (warnings.Count > 0)
        {
            sb.AppendLine("Warnings:");
            foreach (var warning in warnings)
            {
                sb.AppendLine($"- {warning.ScriptName} batch {warning.BatchIndex}/{warning.BatchCount}: SQL {warning.ErrorNumber} {warning.ErrorMessage}");
            }
        }

        return sb.ToString().Trim();
    }

    private static string BuildPathOverview(IReadOnlyList<PatchStep> steps)
    {
        if (steps.Count == 0)
            return "(no steps)";

        var segments = new List<string> { steps[0].FromVersion };
        segments.AddRange(steps.Select(step => step.ToVersion));
        var totalScripts = steps.Sum(step => step.Scripts.Count);
        return $"{string.Join(" -> ", segments)} ({steps.Count} step(s), {totalScripts} script(s))";
    }

    private sealed class CallbackProgress<T>(Action<T> callback) : IProgress<T>
    {
        public void Report(T value) => callback(value);
    }
}
