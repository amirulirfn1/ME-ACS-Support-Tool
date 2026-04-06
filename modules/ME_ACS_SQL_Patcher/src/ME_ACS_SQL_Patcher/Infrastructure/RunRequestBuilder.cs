using System.IO;
using System.Text;
using MagDbPatcher.Models;
using MagDbPatcher.Workflows;

namespace MagDbPatcher.Infrastructure;

public sealed class RunRequestBuilder
{
    private readonly AppRuntimePaths _appPaths;

    public RunRequestBuilder(AppRuntimePaths? appPaths = null)
    {
        _appPaths = appPaths ?? AppRuntimePaths.CreateDefault();
    }

    public PatchRunRequest Build(
        string sourceBakPath,
        string fromVersionId,
        string toVersionId,
        AppSettings settings,
        SqlConnectionSettings connectionSettings)
    {
        var source = (sourceBakPath ?? string.Empty).Trim();
        var from = (fromVersionId ?? string.Empty).Trim();
        var to = (toVersionId ?? string.Empty).Trim();
        var tempFolder = _appPaths.ResolveTempFolder(settings.PatchTempFolder);

        return new PatchRunRequest
        {
            SourceBakPath = source,
            OutputBakPath = BuildOutputBakPath(source, to),
            FromVersionId = from,
            ToVersionId = to,
            TempFolder = tempFolder,
            ConnectionSettings = connectionSettings,
            ExecutionOptions = new PatchExecutionOptions
            {
                ErrorMode = settings.PatchErrorMode,
                WarningThreshold = settings.WarningThreshold
            }
        };
    }

    public string BuildOutputBakPath(string sourceBakPath, string toVersionId)
    {
        if (string.IsNullOrWhiteSpace(sourceBakPath))
            return string.Empty;

        var fullSource = Path.GetFullPath(sourceBakPath);
        var folder = Path.GetDirectoryName(fullSource) ?? Environment.CurrentDirectory;
        var baseName = Path.GetFileNameWithoutExtension(fullSource);
        var suffix = string.IsNullOrWhiteSpace(toVersionId) ? "patched" : $"patched_{SanitizeFileComponent(toVersionId)}";
        return Path.Combine(folder, $"{baseName}_{suffix}.bak");
    }

    private static string SanitizeFileComponent(string value)
    {
        var invalid = Path.GetInvalidFileNameChars();
        var sb = new StringBuilder(value.Length);

        foreach (var ch in value)
            sb.Append(invalid.Contains(ch) ? '-' : ch);

        return sb.ToString();
    }
}
