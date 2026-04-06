using System.IO;
using MagDbPatcher.Infrastructure;

namespace MagDbPatcher.Services;

public sealed class PortableDataMigrationService
{
    private readonly AppRuntimePaths _appPaths;

    public PortableDataMigrationService(AppRuntimePaths appPaths)
    {
        _appPaths = appPaths ?? throw new ArgumentNullException(nameof(appPaths));
    }

    public async Task<PortableDataMigrationResult> EnsureMigratedAsync(IProgress<string>? progress = null)
    {
        Directory.CreateDirectory(_appPaths.UserDataDirectory);

        if (File.Exists(_appPaths.MigrationMarkerPath))
            return PortableDataMigrationResult.None;

        progress?.Report("Checking for legacy portable data...");

        var migratedItems = new List<string>();

        if (ShouldCopyFile(_appPaths.LegacySettingsFilePath, _appPaths.SettingsFilePath))
        {
            await CopyFileAsync(_appPaths.LegacySettingsFilePath, _appPaths.SettingsFilePath);
            migratedItems.Add("settings");
        }

        if (CopyDirectoryIfMissing(_appPaths.LegacyLogsDirectory, _appPaths.LogsDirectory))
            migratedItems.Add("logs");

        if (CopyDirectoryIfMissing(_appPaths.LegacyBackupsDirectory, _appPaths.BackupsDirectory))
            migratedItems.Add("backups");

        if (CopyDirectoryIfEmpty(_appPaths.LegacyPortablePatchesFolder, _appPaths.PatchesFolder))
            migratedItems.Add("patch library");

        await File.WriteAllTextAsync(_appPaths.MigrationMarkerPath, DateTime.UtcNow.ToString("O"));

        return migratedItems.Count == 0
            ? PortableDataMigrationResult.None
            : new PortableDataMigrationResult(true, migratedItems);
    }

    private bool ShouldCopyFile(string sourcePath, string destinationPath)
    {
        if (!File.Exists(sourcePath))
            return false;

        if (PathsEqual(sourcePath, destinationPath))
            return false;

        return !File.Exists(destinationPath);
    }

    private static async Task CopyFileAsync(string sourcePath, string destinationPath)
    {
        var directory = Path.GetDirectoryName(destinationPath);
        if (!string.IsNullOrWhiteSpace(directory))
            Directory.CreateDirectory(directory);

        await using var sourceStream = File.OpenRead(sourcePath);
        await using var destinationStream = File.Create(destinationPath);
        await sourceStream.CopyToAsync(destinationStream);
    }

    private bool CopyDirectoryIfMissing(string sourcePath, string destinationPath)
    {
        if (!Directory.Exists(sourcePath) || PathsEqual(sourcePath, destinationPath))
            return false;

        if (!Directory.Exists(destinationPath))
            Directory.CreateDirectory(destinationPath);

        var copiedAny = false;
        foreach (var file in Directory.GetFiles(sourcePath, "*", SearchOption.AllDirectories))
        {
            var relative = Path.GetRelativePath(sourcePath, file);
            var destinationFile = Path.Combine(destinationPath, relative);
            if (File.Exists(destinationFile))
                continue;

            var destinationDirectory = Path.GetDirectoryName(destinationFile);
            if (!string.IsNullOrWhiteSpace(destinationDirectory))
                Directory.CreateDirectory(destinationDirectory);

            File.Copy(file, destinationFile);
            copiedAny = true;
        }

        return copiedAny;
    }

    private bool CopyDirectoryIfEmpty(string sourcePath, string destinationPath)
    {
        if (!Directory.Exists(sourcePath) || PathsEqual(sourcePath, destinationPath))
            return false;

        Directory.CreateDirectory(destinationPath);
        if (Directory.EnumerateFileSystemEntries(destinationPath).Any())
            return false;

        foreach (var directory in Directory.GetDirectories(sourcePath, "*", SearchOption.AllDirectories))
        {
            var relative = Path.GetRelativePath(sourcePath, directory);
            Directory.CreateDirectory(Path.Combine(destinationPath, relative));
        }

        foreach (var file in Directory.GetFiles(sourcePath, "*", SearchOption.AllDirectories))
        {
            var relative = Path.GetRelativePath(sourcePath, file);
            var destinationFile = Path.Combine(destinationPath, relative);
            var destinationDirectory = Path.GetDirectoryName(destinationFile);
            if (!string.IsNullOrWhiteSpace(destinationDirectory))
                Directory.CreateDirectory(destinationDirectory);

            File.Copy(file, destinationFile, overwrite: true);
        }

        return true;
    }

    private static bool PathsEqual(string left, string right)
        => string.Equals(
            Path.GetFullPath(left),
            Path.GetFullPath(right),
            StringComparison.OrdinalIgnoreCase);
}

public sealed record PortableDataMigrationResult(bool Migrated, IReadOnlyList<string> Items)
{
    public static PortableDataMigrationResult None { get; } = new(false, Array.Empty<string>());
}
