using System.IO.Compression;
using MagDbPatcher.Services;
using Xunit;

namespace MagDbPatcher.Tests;

public class PatchPackServiceTests
{
    [Fact]
    public async Task ImportAsync_FailsWhenPatchPackManifestMissing()
    {
        var root = CreateTempDir();
        try
        {
            var target = Path.Combine(root, "targetPatches");
            Directory.CreateDirectory(target);
            await File.WriteAllTextAsync(Path.Combine(target, "versions.json"), """{ "versions": [], "patches": [] }""");

            var zipPath = Path.Combine(root, "pack.zip");
            using (var zip = ZipFile.Open(zipPath, ZipArchiveMode.Create))
            {
                var entry = zip.CreateEntry("patches/versions.json");
                await using var s = entry.Open();
                await using var w = new StreamWriter(s);
                await w.WriteAsync("""{ "versions": [], "patches": [] }""");
            }

            var svc = new PatchPackService();
            await Assert.ThrowsAsync<InvalidOperationException>(() => svc.ImportAsync(zipPath, target));
        }
        finally
        {
            TryDelete(root);
        }
    }

    [Fact]
    public async Task ImportAsync_FailsOnZipSlipAttempt()
    {
        var root = CreateTempDir();
        try
        {
            var target = Path.Combine(root, "targetPatches");
            Directory.CreateDirectory(target);
            await File.WriteAllTextAsync(Path.Combine(target, "sentinel.txt"), "keep");
            await File.WriteAllTextAsync(Path.Combine(target, "versions.json"), """{ "versions": [], "patches": [] }""");

            var zipPath = Path.Combine(root, "pack.zip");
            using (var zip = ZipFile.Open(zipPath, ZipArchiveMode.Create))
            {
                await WriteTextEntryAsync(zip, "patch-pack.json", """
                {
                  "schemaVersion": 1,
                  "packVersion": "20260203",
                  "releasedAt": "2026-02-03T00:00:00Z",
                  "minAppVersion": "1.0.0",
                  "notes": "",
                  "contentRoot": "patches"
                }
                """);

                await WriteTextEntryAsync(zip, "../evil.txt", "nope");
                await WriteTextEntryAsync(zip, "patches/versions.json", """{ "versions": [], "patches": [] }""");
            }

            var svc = new PatchPackService();
            await Assert.ThrowsAsync<InvalidOperationException>(() => svc.ImportAsync(zipPath, target));

            Assert.True(File.Exists(Path.Combine(target, "sentinel.txt")));
        }
        finally
        {
            TryDelete(root);
        }
    }

    [Fact]
    public async Task ImportAsync_SwapsPatchesFolderAndKeepsBackup()
    {
        var root = CreateTempDir();
        try
        {
            var target = Path.Combine(root, "targetPatches");
            var backups = Path.Combine(root, "backups");
            var archives = Path.Combine(root, "archives");
            Directory.CreateDirectory(target);
            await File.WriteAllTextAsync(Path.Combine(target, "sentinel_old.txt"), "old");
            await File.WriteAllTextAsync(Path.Combine(target, "versions.json"), """{ "versions": [], "patches": [] }""");

            var zipPath = Path.Combine(root, "pack.zip");
            using (var zip = ZipFile.Open(zipPath, ZipArchiveMode.Create))
            {
                await WriteTextEntryAsync(zip, "patch-pack.json", """
                {
                  "schemaVersion": 1,
                  "packVersion": "20260203",
                  "releasedAt": "2026-02-03T00:00:00Z",
                  "minAppVersion": "1.0.0",
                  "notes": "test",
                  "contentRoot": "patches"
                }
                """);

                await WriteTextEntryAsync(zip, "patches/versions.json", """{ "versions": [], "patches": [] }""");
                await WriteTextEntryAsync(zip, "patches/patcher.config.json", """{ "schemaVersion": 1, "versionOrdering": { "mode": "semantic_with_optional_buildDate" }, "autoGenerate": { "buildVersionPattern": "-", "rules": [] } }""");
                await WriteTextEntryAsync(zip, "patches/sentinel_new.txt", "new");
            }

            var svc = new PatchPackService(backups, archives);
            var result = await svc.ImportAsync(zipPath, target);

            Assert.True(File.Exists(Path.Combine(target, "sentinel_new.txt")));
            Assert.False(File.Exists(Path.Combine(target, "sentinel_old.txt")));

            Assert.True(Directory.Exists(result.BackupFolder));
            Assert.StartsWith(Path.GetFullPath(backups), Path.GetFullPath(result.BackupFolder), StringComparison.OrdinalIgnoreCase);
            Assert.True(File.Exists(Path.Combine(result.BackupFolder, "sentinel_old.txt")));
            Assert.False(string.IsNullOrWhiteSpace(result.ArchivedPackPath));
            Assert.StartsWith(Path.GetFullPath(archives), Path.GetFullPath(result.ArchivedPackPath!), StringComparison.OrdinalIgnoreCase);
            Assert.True(File.Exists(result.ArchivedPackPath!));
        }
        finally
        {
            TryDelete(root);
        }
    }

    [Fact]
    public async Task ImportAsync_DoesNotSwapPatchesFolder_WhenArchivingFails()
    {
        var root = CreateTempDir();
        try
        {
            var target = Path.Combine(root, "targetPatches");
            var backups = Path.Combine(root, "backups");
            var archivePathBlockedByFile = Path.Combine(root, "archives.blocked");
            Directory.CreateDirectory(target);
            await File.WriteAllTextAsync(Path.Combine(target, "sentinel_old.txt"), "old");
            await File.WriteAllTextAsync(Path.Combine(target, "versions.json"), """{ "versions": [], "patches": [] }""");
            await File.WriteAllTextAsync(archivePathBlockedByFile, "not a directory");

            var zipPath = Path.Combine(root, "pack.zip");
            using (var zip = ZipFile.Open(zipPath, ZipArchiveMode.Create))
            {
                await WriteTextEntryAsync(zip, "patch-pack.json", """
                {
                  "schemaVersion": 1,
                  "packVersion": "20260204",
                  "releasedAt": "2026-02-04T00:00:00Z",
                  "minAppVersion": "1.0.0",
                  "notes": "test",
                  "contentRoot": "patches"
                }
                """);

                await WriteTextEntryAsync(zip, "patches/versions.json", """{ "versions": [], "patches": [] }""");
                await WriteTextEntryAsync(zip, "patches/sentinel_new.txt", "new");
            }

            var svc = new PatchPackService(backups, archivePathBlockedByFile);
            await Assert.ThrowsAnyAsync<IOException>(() => svc.ImportAsync(zipPath, target));

            Assert.True(File.Exists(Path.Combine(target, "sentinel_old.txt")));
            Assert.False(File.Exists(Path.Combine(target, "sentinel_new.txt")));
        }
        finally
        {
            TryDelete(root);
        }
    }

    private static async Task WriteTextEntryAsync(ZipArchive zip, string path, string content)
    {
        var entry = zip.CreateEntry(path);
        await using var s = entry.Open();
        await using var w = new StreamWriter(s);
        await w.WriteAsync(content);
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
