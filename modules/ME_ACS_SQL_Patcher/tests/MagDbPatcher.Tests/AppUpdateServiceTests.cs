using MagDbPatcher.Services;
using Xunit;
using System.Security.Cryptography;

namespace MagDbPatcher.Tests;

public class AppUpdateServiceTests
{
    [Fact]
    public async Task CheckForUpdatesAsync_SupportsLocalFolderFeeds()
    {
        var root = CreateTempDir();
        try
        {
            var feed = Path.Combine(root, "feed");
            Directory.CreateDirectory(feed);

            await File.WriteAllTextAsync(Path.Combine(feed, "latest.json"), """
            {
              "buildDate": "2026-04-02T00:00:00Z",
              "installerName": "ME_ACS_SQL_Patcher-win-Setup.exe",
              "installerSha256": "__HASH__"
            }
            """.Replace("__HASH__", ComputeSha256Hex("stub")));
            await File.WriteAllTextAsync(Path.Combine(feed, "ME_ACS_SQL_Patcher-win-Setup.exe"), "stub");

            var service = new BuildDateUpdateService();
            var result = await service.CheckForUpdatesAsync(feed);

            Assert.True(result.IsUpdateAvailable);
            Assert.Equal(Path.Combine(feed, "ME_ACS_SQL_Patcher-win-Setup.exe"), result.InstallerUrl);
        }
        finally
        {
            TryDelete(root);
        }
    }

    [Fact]
    public async Task CheckForUpdatesAsync_RejectsLocalInstallerHashMismatch()
    {
        var root = CreateTempDir();
        try
        {
            var feed = Path.Combine(root, "feed");
            Directory.CreateDirectory(feed);

            await File.WriteAllTextAsync(Path.Combine(feed, "latest.json"), """
            {
              "buildDate": "2026-04-02T00:00:00Z",
              "installerName": "ME_ACS_SQL_Patcher-win-Setup.exe",
              "installerSha256": "deadbeef"
            }
            """);
            await File.WriteAllTextAsync(Path.Combine(feed, "ME_ACS_SQL_Patcher-win-Setup.exe"), "stub");

            var service = new BuildDateUpdateService();
            var ex = await Assert.ThrowsAsync<InvalidOperationException>(() => service.CheckForUpdatesAsync(feed));

            Assert.Contains("integrity verification", ex.Message, StringComparison.OrdinalIgnoreCase);
        }
        finally
        {
            TryDelete(root);
        }
    }

    [Fact]
    public async Task CheckForUpdatesAsync_UsesPatchCatalogHashForSameBuildRefreshes()
    {
        var root = CreateTempDir();
        var metadataPath = Path.Combine(AppContext.BaseDirectory, "patch-catalog.json");
        var previousMetadata = File.Exists(metadataPath) ? await File.ReadAllTextAsync(metadataPath) : null;
        try
        {
            await File.WriteAllTextAsync(metadataPath, """
            {
              "version": "7.2.4",
              "label": "7.2.4 | 3 scripts | 02 Apr 2026 09:00 MYT",
              "summary": "1 version(s), 1 patch link(s), 3 script(s)",
              "hash": "localhash"
            }
            """);

            var feed = Path.Combine(root, "feed");
            Directory.CreateDirectory(feed);

            await File.WriteAllTextAsync(Path.Combine(feed, "latest.json"), """
            {
              "buildDate": "2000-01-01T00:00:00Z",
              "installerName": "ME_ACS_SQL_Patcher-win-Setup.exe",
              "installerSha256": "__HASH__",
              "patchCatalogLabel": "7.2.4 | 4 scripts | 02 Apr 2026 10:00 MYT",
              "patchCatalogHash": "serverhash",
              "releaseNotes": "Bundled patch catalog refreshed."
            }
            """.Replace("__HASH__", ComputeSha256Hex("stub")));
            await File.WriteAllTextAsync(Path.Combine(feed, "ME_ACS_SQL_Patcher-win-Setup.exe"), "stub");

            var service = new BuildDateUpdateService();
            var result = await service.CheckForUpdatesAsync(feed);

            Assert.True(result.IsUpdateAvailable);
            Assert.Equal("7.2.4 | 4 scripts | 02 Apr 2026 10:00 MYT", result.ServerPatchCatalogLabel);
            Assert.Contains("Bundled patch catalog refreshed.", result.Message, StringComparison.OrdinalIgnoreCase);
        }
        finally
        {
            RestoreFile(metadataPath, previousMetadata);
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

    private static void RestoreFile(string path, string? previousContent)
    {
        try
        {
            if (previousContent == null)
            {
                if (File.Exists(path))
                    File.Delete(path);
                return;
            }

            File.WriteAllText(path, previousContent);
        }
        catch
        {
        }
    }

    private static string ComputeSha256Hex(string value)
    {
        var bytes = System.Text.Encoding.UTF8.GetBytes(value);
        return Convert.ToHexString(SHA256.HashData(bytes)).ToLowerInvariant();
    }
}
