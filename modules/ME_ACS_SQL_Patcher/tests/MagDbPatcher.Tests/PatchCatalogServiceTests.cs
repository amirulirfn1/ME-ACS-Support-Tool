using System.Text.Json;
using MagDbPatcher.Models;
using MagDbPatcher.Services;
using Xunit;

namespace MagDbPatcher.Tests;

public class PatchCatalogServiceTests
{
    [Fact]
    public async Task ScanAsync_DetectsFolderVersions_AndScripts()
    {
        var root = CreateTempDir();
        try
        {
            var patches = Path.Combine(root, "patches");
            Directory.CreateDirectory(patches);
            Directory.CreateDirectory(Path.Combine(patches, "1.0"));
            Directory.CreateDirectory(Path.Combine(patches, "2.0"));
            await File.WriteAllTextAsync(Path.Combine(patches, "2.0", "a.sql"), "SELECT 1;");

            await File.WriteAllTextAsync(Path.Combine(patches, "versions.json"), """
            {
              "versions": [
                { "id": "1.0", "name": "1.0", "upgradesTo": null, "order": 1 }
              ],
              "patches": []
            }
            """);

            var svc = new PatchCatalogService();
            var snapshot = await svc.ScanAsync(patches);

            Assert.Contains(snapshot.Versions, v => v.Id == "2.0");
            Assert.Contains(snapshot.AvailableScripts, s => s == "2.0/a.sql");
        }
        finally
        {
            TryDelete(root);
        }
    }

    [Fact]
    public async Task ApplyAsync_NormalizesScriptPathSeparators()
    {
        var root = CreateTempDir();
        try
        {
            var patches = Path.Combine(root, "patches");
            Directory.CreateDirectory(patches);
            Directory.CreateDirectory(Path.Combine(patches, "2.0"));
            await File.WriteAllTextAsync(Path.Combine(patches, "2.0", "a.sql"), "SELECT 1;");

            await File.WriteAllTextAsync(Path.Combine(patches, "versions.json"), """
            {
              "versions": [
                { "id": "1.0", "name": "1.0", "upgradesTo": null, "order": 1 },
                { "id": "2.0", "name": "2.0", "upgradesTo": null, "order": 2 }
              ],
              "patches": []
            }
            """);

            var svc = new PatchCatalogService();
            await svc.ApplyAsync(patches, new PatchCatalogMutation
            {
                PatchLinks = new List<PatchLinkMutation>
                {
                    new()
                    {
                        Type = PatchLinkMutationType.AddOrUpdate,
                        FromVersion = "1.0",
                        ToVersion = "2.0",
                        Scripts = new List<string> { @"2.0\a.sql" },
                        Manual = true
                    }
                }
            });

            var text = await File.ReadAllTextAsync(Path.Combine(patches, "versions.json"));
            Assert.Contains("2.0/a.sql", text);
        }
        finally
        {
            TryDelete(root);
        }
    }

    [Fact]
    public async Task ValidateAsync_ReturnsErrors_ForMissingScripts()
    {
        var root = CreateTempDir();
        try
        {
            var patches = Path.Combine(root, "patches");
            Directory.CreateDirectory(patches);
            Directory.CreateDirectory(Path.Combine(patches, "1.0"));
            Directory.CreateDirectory(Path.Combine(patches, "2.0"));

            await File.WriteAllTextAsync(Path.Combine(patches, "versions.json"), """
            {
              "versions": [
                { "id": "1.0", "name": "1.0", "upgradesTo": null, "order": 1 },
                { "id": "2.0", "name": "2.0", "upgradesTo": null, "order": 2 }
              ],
              "patches": [
                { "from": "1.0", "to": "2.0", "scripts": ["2.0/missing.sql"] }
              ]
            }
            """);

            var svc = new PatchCatalogService();
            var validation = await svc.ValidateAsync(patches);

            Assert.True(validation.HasErrors);
        }
        finally
        {
            TryDelete(root);
        }
    }

    [Fact]
    public async Task VersionConfigRepository_SaveAsync_CreatesBackup_OnReplace()
    {
        var root = CreateTempDir();
        try
        {
            var path = Path.Combine(root, "versions.json");
            var repo = new VersionConfigRepository();
            await repo.SaveAsync(path, new VersionConfig());
            await repo.SaveAsync(path, new VersionConfig
            {
                Versions = new List<VersionInfo> { new() { Id = "1.0", Name = "1.0", Order = 1 } }
            });

            Assert.True(File.Exists(path + ".bak"));
        }
        finally
        {
            TryDelete(root);
        }
    }

    [Fact]
    public async Task ValidateAsync_RepoPatchLibraryHasNoErrors()
    {
        var svc = new PatchCatalogService();
        var validation = await svc.ValidateAsync(GetRepoPatchesPath());

        Assert.False(validation.HasErrors, string.Join(Environment.NewLine, validation.Errors.Select(e => e.Message)));
    }

    private static string CreateTempDir()
    {
        var path = Path.Combine(Path.GetTempPath(), "MagDbPatcher.Tests", Guid.NewGuid().ToString("N"));
        Directory.CreateDirectory(path);
        return path;
    }

    private static string GetRepoPatchesPath()
    {
        var current = new DirectoryInfo(AppContext.BaseDirectory);
        while (current != null)
        {
            var candidate = Path.Combine(current.FullName, "patches", "versions.json");
            if (File.Exists(candidate))
                return Path.GetDirectoryName(candidate)!;

            current = current.Parent;
        }

        throw new DirectoryNotFoundException("Could not locate repository patches folder.");
    }

    private static void TryDelete(string path)
    {
        try { Directory.Delete(path, true); } catch { }
    }
}
