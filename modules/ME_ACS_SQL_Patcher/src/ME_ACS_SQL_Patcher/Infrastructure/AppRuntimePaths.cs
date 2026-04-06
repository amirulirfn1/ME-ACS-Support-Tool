using System.IO;

namespace MagDbPatcher.Infrastructure;

public sealed class AppRuntimePaths
{
    private const string ProductFolderName = "MagDbPatcher";
    private const string MachineDataFolderName = "ME_ACS_SQL_Patcher";

    public AppRuntimePaths(string baseDirectory, string? userDataDirectory = null, string? machineDataDirectory = null)
    {
        if (string.IsNullOrWhiteSpace(baseDirectory))
            throw new ArgumentException("Base directory is required.", nameof(baseDirectory));

        RootDirectory = Path.GetFullPath(baseDirectory);
        UserDataDirectory = ResolveUserDataDirectory(userDataDirectory);
        MachineDataDirectory = ResolveMachineDataDirectory(machineDataDirectory);
    }

    public string RootDirectory { get; }
    public string AppInstallDirectory => RootDirectory;
    public string UserDataDirectory { get; }
    public string MachineDataDirectory { get; }
    public string BundledPatchesFolder => Path.Combine(AppInstallDirectory, "patches");
    public string LegacyPortablePatchesFolder => Path.Combine(RootDirectory, "patches");
    public string PatchesFolder => Path.Combine(UserDataDirectory, "patches");
    public string SettingsFilePath => Path.Combine(UserDataDirectory, "settings.json");
    public string LogsDirectory => Path.Combine(UserDataDirectory, "logs");
    public string DiagnosticsLogPath => Path.Combine(LogsDirectory, "diagnostics.log");
    public string StartupErrorLogPath => Path.Combine(LogsDirectory, "startup-errors.log");
    public string LegacyPortableTempFolder => Path.Combine(RootDirectory, "temp");
    public string TempFolder => Path.Combine(MachineDataDirectory, "temp");
    public string BackupsDirectory => Path.Combine(UserDataDirectory, "backups");
    public string ImportedPacksDirectory => Path.Combine(UserDataDirectory, "patch-packs");
    public string MigrationMarkerPath => Path.Combine(UserDataDirectory, ".portable-migration-complete");
    public string LegacySettingsFilePath => Path.Combine(RootDirectory, "settings.json");
    public string LegacyLogsDirectory => Path.Combine(RootDirectory, "logs");
    public string LegacyBackupsDirectory => Path.Combine(RootDirectory, "backups");

    public static AppRuntimePaths CreateDefault() => new(AppContext.BaseDirectory);

    public string ResolveTempFolder(string? configuredTempFolder)
    {
        if (string.IsNullOrWhiteSpace(configuredTempFolder))
            return TempFolder;

        var fullPath = Path.GetFullPath(configuredTempFolder);
        if (string.Equals(fullPath, Path.GetFullPath(LegacyPortableTempFolder), StringComparison.OrdinalIgnoreCase))
            return TempFolder;

        return fullPath;
    }

    private string ResolveUserDataDirectory(string? userDataDirectory)
    {
        if (!string.IsNullOrWhiteSpace(userDataDirectory))
            return Path.GetFullPath(userDataDirectory);

        var localAppData = Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData);
        if (string.IsNullOrWhiteSpace(localAppData))
            return RootDirectory;

        return Path.GetFullPath(Path.Combine(localAppData, ProductFolderName));
    }

    private string ResolveMachineDataDirectory(string? machineDataDirectory)
    {
        if (!string.IsNullOrWhiteSpace(machineDataDirectory))
            return Path.GetFullPath(machineDataDirectory);

        var commonAppData = Environment.GetFolderPath(Environment.SpecialFolder.CommonApplicationData);
        if (string.IsNullOrWhiteSpace(commonAppData))
            return UserDataDirectory;

        return Path.GetFullPath(Path.Combine(commonAppData, MachineDataFolderName));
    }
}
