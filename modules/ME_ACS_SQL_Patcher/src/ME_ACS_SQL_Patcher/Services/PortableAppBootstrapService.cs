using System.IO;
using System.Text;
using MagDbPatcher.Infrastructure;

namespace MagDbPatcher.Services;

public sealed class PortableAppBootstrapService
{
    private readonly AppRuntimePaths _appPaths;
    private readonly PortableDataMigrationService _migrationService;

    public PortableAppBootstrapService(AppRuntimePaths appPaths)
    {
        _appPaths = appPaths ?? throw new ArgumentNullException(nameof(appPaths));
        _migrationService = new PortableDataMigrationService(_appPaths);
    }

    public async Task EnsureReadyAsync(IProgress<string>? progress = null)
    {
        progress?.Report("Preparing application workspace...");
        Directory.CreateDirectory(_appPaths.UserDataDirectory);
        Directory.CreateDirectory(_appPaths.LogsDirectory);
        Directory.CreateDirectory(_appPaths.BackupsDirectory);
        Directory.CreateDirectory(_appPaths.ImportedPacksDirectory);
        Directory.CreateDirectory(_appPaths.TempFolder);

        var migration = await _migrationService.EnsureMigratedAsync(progress);
        if (migration.Migrated)
        {
            progress?.Report($"Imported legacy portable data: {string.Join(", ", migration.Items)}");
        }

        progress?.Report("Checking writable app-data folders...");
        EnsureDirectoryWritable(Path.GetDirectoryName(_appPaths.SettingsFilePath) ?? _appPaths.UserDataDirectory);
        EnsureWritable(Path.Combine(_appPaths.LogsDirectory, ".write-test"));
        EnsureWritable(Path.Combine(_appPaths.ImportedPacksDirectory, ".write-test"));

        progress?.Report("Verifying bundled patch library...");
        if (!Directory.Exists(_appPaths.BundledPatchesFolder))
        {
            throw new InvalidOperationException(
                $"Installed app is missing the required bundled patches folder:{Environment.NewLine}{_appPaths.BundledPatchesFolder}");
        }

        var versionsPath = Path.Combine(_appPaths.BundledPatchesFolder, "versions.json");
        if (!File.Exists(versionsPath))
        {
            throw new InvalidOperationException(
                $"Installed app is missing bundled patches\\versions.json:{Environment.NewLine}{versionsPath}");
        }

        progress?.Report("Loading bundled patch catalog...");
        var versionService = new VersionService(_appPaths.BundledPatchesFolder);
        await versionService.LoadVersionsAsync();

        if (!versionService.LastValidationResult.HasErrors)
            return;

        var builder = new StringBuilder();
        builder.AppendLine("Bundled patch library validation failed.");
        builder.AppendLine("Fix the installed app package contents and try again.");

        foreach (var error in versionService.LastValidationResult.Errors.Take(5))
            builder.AppendLine($"- {error.Message}");

        if (versionService.LastValidationResult.Errors.Count > 5)
            builder.AppendLine($"- {versionService.LastValidationResult.Errors.Count - 5} more error(s)");

        throw new InvalidOperationException(builder.ToString().Trim());
    }

    private static void EnsureWritable(string probePath)
    {
        var directory = Path.GetDirectoryName(probePath);
        if (!string.IsNullOrWhiteSpace(directory))
            Directory.CreateDirectory(directory);

        File.WriteAllText(probePath, "ok");
        File.Delete(probePath);
    }

    private static void EnsureDirectoryWritable(string directoryPath)
    {
        if (string.IsNullOrWhiteSpace(directoryPath))
            throw new ArgumentException("Directory path is required.", nameof(directoryPath));

        EnsureWritable(Path.Combine(directoryPath, ".write-test"));
    }
}
