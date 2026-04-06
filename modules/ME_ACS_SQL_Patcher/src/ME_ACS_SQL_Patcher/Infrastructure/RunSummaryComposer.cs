using System.IO;
using MagDbPatcher.Models;
using MagDbPatcher.Services;

namespace MagDbPatcher.Infrastructure;

public sealed class RunSummaryComposer
{
    public RunSummaryState Compose(RunSummaryInput input)
    {
        var sourceText = BuildSourceText(input.SourceBakPath, out var hint, out var hintKind);
        var pathText = BuildUpgradePathText(input.FromVersionId, input.ToVersionId, input.VersionService);
        var planText = BuildPlanText(input.FromVersionId, input.ToVersionId, input.VersionService);
        var connectionText = BuildConnectionText(input.SqlServer, input.SqlAuthMode, input.SqlConnectionTestPassed);
        var outputText = BuildOutputText(input.OutputBakPath);
        var safeguardsText = BuildSafeguardsText(input.TempFolder, input.ErrorMode, input.WarningThreshold);

        return new RunSummaryState(
            SourceFileHint: hint,
            SourceFileHintKind: hintKind,
            SourceText: sourceText,
            UpgradePathText: pathText,
            ConnectionText: connectionText,
            PlanText: planText,
            OutputText: outputText,
            SafeguardsText: safeguardsText);
    }

    private static string BuildSourceText(string sourceBakPath, out string hint, out SourceFileHintKind hintKind)
    {
        hint = string.Empty;
        hintKind = SourceFileHintKind.None;

        if (string.IsNullOrWhiteSpace(sourceBakPath))
            return "Select a source backup file to preview the run.";

        var trimmed = sourceBakPath.Trim();
        if (!File.Exists(trimmed))
        {
            hint = "File not found.";
            hintKind = SourceFileHintKind.Error;
            return trimmed;
        }

        var info = new FileInfo(trimmed);
        var size = FormatSize(info.Length);
        hint = $"{info.Name} ({size})";
        hintKind = SourceFileHintKind.Success;
        return $"{trimmed}{Environment.NewLine}Detected: {info.Name} ({size})";
    }

    private static string BuildUpgradePathText(string fromVersionId, string toVersionId, IVersionService? versionService)
    {
        if (string.IsNullOrWhiteSpace(fromVersionId) || string.IsNullOrWhiteSpace(toVersionId))
            return "Select source and target versions to preview the upgrade path.";

        if (versionService == null)
            return $"{fromVersionId} -> {toVersionId}";

        try
        {
            var steps = versionService.CalculateUpgradePath(fromVersionId, toVersionId);
            var totalScripts = steps.Sum(step => step.Scripts.Count);
            return $"{fromVersionId} -> {toVersionId}{Environment.NewLine}{steps.Count} step(s), {totalScripts} script(s)";
        }
        catch (Exception ex)
        {
            return $"No path available: {ex.Message}";
        }
    }

    private static string BuildPlanText(string fromVersionId, string toVersionId, IVersionService? versionService)
    {
        if (string.IsNullOrWhiteSpace(fromVersionId) || string.IsNullOrWhiteSpace(toVersionId))
            return "Choose versions to calculate steps and script count.";

        if (versionService == null)
            return "Patch engine is still loading.";

        try
        {
            var steps = versionService.CalculateUpgradePath(fromVersionId, toVersionId);
            var totalScripts = steps.Sum(step => step.Scripts.Count);
            return $"{steps.Count} step(s), {totalScripts} script(s){Environment.NewLine}Ready path: {fromVersionId} to {toVersionId}";
        }
        catch (Exception ex)
        {
            return $"Path check failed: {ex.Message}";
        }
    }

    private static string BuildConnectionText(string sqlServer, SqlAuthMode authMode, bool sqlConnectionTestPassed)
    {
        var server = string.IsNullOrWhiteSpace(sqlServer) ? ".\\MAGSQL" : sqlServer.Trim();
        var auth = authMode == SqlAuthMode.SqlLogin ? "SQL Login" : "Windows";
        var testStatus = sqlConnectionTestPassed ? "Tested successfully" : "Test not confirmed yet";
        return $"Server: {server}{Environment.NewLine}Auth: {auth}{Environment.NewLine}Connection: {testStatus}";
    }

    private static string BuildOutputText(string outputBakPath)
    {
        if (string.IsNullOrWhiteSpace(outputBakPath))
            return "Select a source backup to resolve the output path.";

        return outputBakPath.Trim();
    }

    private static string BuildSafeguardsText(string tempFolder, PatchErrorMode errorMode, int warningThreshold)
    {
        var normalizedThreshold = warningThreshold <= 0 ? 10 : warningThreshold;
        var temp = string.IsNullOrWhiteSpace(tempFolder) ? AppRuntimePaths.CreateDefault().TempFolder : tempFolder.Trim();
        var mode = errorMode == PatchErrorMode.FailFast ? "Fail fast on SQL errors" : "Warn and continue on SQL errors";

        return $"Temp: {temp}{Environment.NewLine}Mode: {mode}{Environment.NewLine}Warning threshold: {normalizedThreshold}";
    }

    private static string FormatSize(long bytes)
    {
        const double Kb = 1024;
        const double Mb = Kb * 1024;
        const double Gb = Mb * 1024;

        if (bytes >= Gb)
            return $"{bytes / Gb:F1} GB";
        if (bytes >= Mb)
            return $"{bytes / Mb:F0} MB";
        if (bytes >= Kb)
            return $"{bytes / Kb:F0} KB";
        return $"{bytes} B";
    }
}
