using MagDbPatcher.Services;
using Xunit;

namespace MagDbPatcher.Tests;

public class PortableDataMigrationServiceTests
{
    [Fact]
    public async Task EnsureMigratedAsync_CopiesLegacyPortableDataIntoManagedLocations()
    {
        var root = CreateTempDir();
        try
        {
            var appPaths = TestAppPaths.Create(root);
            Directory.CreateDirectory(appPaths.BundledPatchesFolder);
            Directory.CreateDirectory(appPaths.LegacyLogsDirectory);
            Directory.CreateDirectory(appPaths.LegacyBackupsDirectory);
            Directory.CreateDirectory(Path.Combine(appPaths.LegacyPortablePatchesFolder, "7.2"));

            await File.WriteAllTextAsync(appPaths.LegacySettingsFilePath, """{ "lastSqlServer": ".\\MAGSQL" }""");
            await File.WriteAllTextAsync(Path.Combine(appPaths.LegacyLogsDirectory, "session.log"), "legacy-log");
            await File.WriteAllTextAsync(Path.Combine(appPaths.LegacyBackupsDirectory, "db.bak"), "legacy-backup");
            await File.WriteAllTextAsync(Path.Combine(appPaths.LegacyPortablePatchesFolder, "versions.json"), """{ "versions": [], "patches": [] }""");
            await File.WriteAllTextAsync(Path.Combine(appPaths.LegacyPortablePatchesFolder, "7.2", "patch.sql"), "SELECT 1;");

            var service = new PortableDataMigrationService(appPaths);
            var result = await service.EnsureMigratedAsync();

            Assert.True(result.Migrated);
            Assert.Contains("settings", result.Items);
            Assert.Contains("logs", result.Items);
            Assert.Contains("backups", result.Items);
            Assert.Contains("patch library", result.Items);
            Assert.True(File.Exists(appPaths.SettingsFilePath));
            Assert.True(File.Exists(Path.Combine(appPaths.LogsDirectory, "session.log")));
            Assert.True(File.Exists(Path.Combine(appPaths.BackupsDirectory, "db.bak")));
            Assert.True(File.Exists(Path.Combine(appPaths.PatchesFolder, "7.2", "patch.sql")));
            Assert.True(File.Exists(appPaths.MigrationMarkerPath));
        }
        finally
        {
            TryDelete(root);
        }
    }

    private static string CreateTempDir()
    {
        var dir = Path.Combine(Path.GetTempPath(), "MagDbPatcherTests_" + Guid.NewGuid().ToString("N"));
        Directory.CreateDirectory(dir);
        return dir;
    }

    private static void TryDelete(string path)
    {
        try
        {
            if (Directory.Exists(path))
                Directory.Delete(path, recursive: true);
        }
        catch
        {
        }
    }
}
