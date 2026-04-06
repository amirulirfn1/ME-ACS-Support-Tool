using System.IO;
using System.Text;
using MagDbPatcher.Models;
using MagDbPatcher.Services;
using MagDbPatcher.Workflows;

namespace MagDbPatcher.Infrastructure;

public sealed class DiagnosticsComposer
{
    private readonly RunWarningFormatter _warningFormatter = new();

    public string BuildPatchPlan(PatchRunRequest request, IVersionService? versionService)
    {
        var sb = new StringBuilder();

        sb.AppendLine("Patch Plan");
        sb.AppendLine($"Source: {request.SourceBakPath}");
        sb.AppendLine($"Output: {request.OutputBakPath}");
        sb.AppendLine($"From: {request.FromVersionId}");
        sb.AppendLine($"To: {request.ToVersionId}");
        sb.AppendLine($"SQL: {request.ConnectionSettings.Server}");
        sb.AppendLine($"Temp: {request.TempFolder}");
        sb.AppendLine($"Mode: {request.ExecutionOptions.ErrorMode}");
        sb.AppendLine();

        if (versionService != null &&
            !string.IsNullOrWhiteSpace(request.FromVersionId) &&
            !string.IsNullOrWhiteSpace(request.ToVersionId))
        {
            try
            {
                var steps = versionService.CalculateUpgradePath(request.FromVersionId, request.ToVersionId);
                sb.AppendLine($"Steps: {steps.Count}");
                sb.AppendLine($"Scripts: {steps.Sum(s => s.Scripts.Count)}");
                sb.AppendLine("Path strategy: shortest-step BFS over strictly increasing version order");
                sb.AppendLine();

                foreach (var step in steps)
                {
                    sb.AppendLine($"{step.FromVersion} -> {step.ToVersion}");
                    foreach (var script in step.Scripts)
                        sb.AppendLine($"  - {Path.GetFileName(script)}");
                    sb.AppendLine();
                }
            }
            catch (Exception ex)
            {
                sb.AppendLine($"Plan unavailable: {ex.Message}");
            }
        }
        else
        {
            sb.AppendLine("Plan unavailable: Select source and target versions.");
        }

        return sb.ToString().Trim();
    }

    public string BuildDiagnostics(
        string status,
        string resultSummary,
        IEnumerable<SqlBatchWarning> runWarnings,
        string runtimeLog,
        string patchPlan,
        IEnumerable<string>? nonFatalDiagnostics)
    {
        var warnings = runWarnings?.ToList() ?? new List<SqlBatchWarning>();
        var warningLines = _warningFormatter.BuildDiagnosticsLines(warnings);

        var sb = new StringBuilder();
        sb.AppendLine("Diagnostics");
        sb.AppendLine($"Status: {status}");
        sb.AppendLine($"Result: {resultSummary}");
        sb.AppendLine($"Warnings: {warnings.Count}");
        sb.AppendLine();
        sb.AppendLine("Patch Plan");
        sb.AppendLine("----------");
        sb.AppendLine(patchPlan);
        sb.AppendLine();

        if (warningLines.Count > 0)
        {
            sb.AppendLine("Warnings");
            sb.AppendLine("--------");
            foreach (var line in warningLines)
                sb.AppendLine(line);
            sb.AppendLine();
        }

        sb.AppendLine("Runtime Log");
        sb.AppendLine("-----------");
        sb.AppendLine(runtimeLog);

        if (nonFatalDiagnostics != null)
        {
            var nonFatal = nonFatalDiagnostics.Where(x => !string.IsNullOrWhiteSpace(x)).ToList();
            if (nonFatal.Count > 0)
            {
                sb.AppendLine();
                sb.AppendLine("Non-Fatal Diagnostics");
                sb.AppendLine("---------------------");
                foreach (var line in nonFatal)
                    sb.AppendLine($"- {line}");
            }
        }

        return sb.ToString().Trim();
    }
}
