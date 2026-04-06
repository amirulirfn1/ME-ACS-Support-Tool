using MagDbPatcher.Models;

namespace MagDbPatcher.Infrastructure;

public sealed class SettingsBinder
{
    private readonly AppRuntimePaths _appPaths;

    public SettingsBinder(AppRuntimePaths? appPaths = null)
    {
        _appPaths = appPaths ?? AppRuntimePaths.CreateDefault();
    }

    public SettingsViewSnapshot BuildViewSnapshot(AppSettings settings)
    {
        return new SettingsViewSnapshot
        {
            LastImportedPack = settings.LastImportedPatchPack ?? string.Empty,
            RecentBackups = settings.RecentBackupFiles
                .Where(p => !string.IsNullOrWhiteSpace(p))
                .Distinct(StringComparer.OrdinalIgnoreCase)
                .Take(5)
                .ToList(),
            LastSqlServer = settings.LastSqlServer ?? string.Empty,
            SqlUsername = settings.SqlUsername ?? string.Empty,
            SqlAuthMode = settings.SqlAuthMode,
            PatchTempFolder = _appPaths.ResolveTempFolder(settings.PatchTempFolder),
            WarningThreshold = settings.WarningThreshold <= 0 ? 10 : settings.WarningThreshold,
            PatchErrorMode = settings.PatchErrorMode
        };
    }

    public AppSettings BuildPersistedSettings(SettingsPersistInput input)
    {
        return new AppSettings
        {
            PatchTempFolder = _appPaths.ResolveTempFolder(input.Existing.PatchTempFolder),
            WarningThreshold = input.Existing.WarningThreshold <= 0 ? 10 : input.Existing.WarningThreshold,
            PatchErrorMode = input.Existing.PatchErrorMode,
            PatchesFolder = input.PatchesFolder,
            LastSqlServer = input.LastSqlServer,
            LastOutputFolder = input.LastOutputFolder,
            RecentBackupFiles = input.RecentBackupFiles.ToList(),
            LastImportedPatchPack = NormalizeLastImportedPatchPack(input.LastImportedPatchPack),
            SqlAuthMode = input.SqlAuthMode,
            SqlUsername = input.SqlAuthMode == SqlAuthMode.SqlLogin ? input.SqlUsername : null,
            IsDarkTheme = input.Existing.IsDarkTheme
        };
    }

    private static string? NormalizeLastImportedPatchPack(string? value)
    {
        if (string.IsNullOrWhiteSpace(value))
            return null;

        var trimmed = value.Trim();
        var lines = trimmed
            .Split(['\r', '\n'], StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);
        var summaryLine = lines.FirstOrDefault(line =>
            line.StartsWith("Last imported pack:", StringComparison.OrdinalIgnoreCase));

        if (summaryLine == null)
            return trimmed;

        var label = summaryLine["Last imported pack:".Length..].Trim().TrimEnd('.');
        return label.Equals("none yet", StringComparison.OrdinalIgnoreCase) ? null : label;
    }
}

public sealed class SettingsViewSnapshot
{
    public string LastImportedPack { get; init; } = string.Empty;
    public IReadOnlyList<string> RecentBackups { get; init; } = Array.Empty<string>();
    public string LastSqlServer { get; init; } = string.Empty;
    public string SqlUsername { get; init; } = string.Empty;
    public SqlAuthMode SqlAuthMode { get; init; } = SqlAuthMode.Windows;
    public string PatchTempFolder { get; init; } = AppRuntimePaths.CreateDefault().TempFolder;
    public int WarningThreshold { get; init; } = 10;
    public PatchErrorMode PatchErrorMode { get; init; } = PatchErrorMode.WarnAndContinue;
}

public sealed class SettingsPersistInput
{
    public AppSettings Existing { get; init; } = new();
    public string PatchesFolder { get; init; } = string.Empty;
    public string LastSqlServer { get; init; } = string.Empty;
    public string? LastOutputFolder { get; init; }
    public IReadOnlyList<string> RecentBackupFiles { get; init; } = Array.Empty<string>();
    public string? LastImportedPatchPack { get; init; }
    public SqlAuthMode SqlAuthMode { get; init; } = SqlAuthMode.Windows;
    public string? SqlUsername { get; init; }
}
