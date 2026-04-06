using MagDbPatcher.Services;
using Xunit;

namespace MagDbPatcher.Tests;

public class VersionServiceTests
{
    [Fact]
    public async Task GetSourceVersions_IncludesVersionsThatArePatchSources()
    {
        var root = CreateTempDir();
        try
        {
            var patches = Path.Combine(root, "patches");
            Directory.CreateDirectory(patches);

            Directory.CreateDirectory(Path.Combine(patches, "6.5"));
            Directory.CreateDirectory(Path.Combine(patches, "7.0"));
            await File.WriteAllTextAsync(Path.Combine(patches, "7.0", "patch.sql"), "SELECT 1;");

            var json = """
                       {
                         "versions": [
                           { "id": "6.5", "name": "6.5", "upgradesTo": null, "order": 1 },
                           { "id": "7.0", "name": "7.0", "upgradesTo": null, "order": 2 }
                         ],
                         "patches": [
                           { "from": "6.5", "to": "7.0", "scripts": ["7.0/patch.sql"] }
                         ]
                       }
                       """;
            await File.WriteAllTextAsync(Path.Combine(patches, "versions.json"), json);

            var svc = new VersionService(patches);
            await svc.LoadVersionsAsync();

            Assert.False(svc.LastValidationResult.HasErrors);
            Assert.Contains(svc.GetSourceVersions(), v => v.Id == "6.5");
        }
        finally
        {
            TryDelete(root);
        }
    }

    [Fact]
    public async Task GetTargetVersions_ReturnsOnlyReachableHigherOrderVersions()
    {
        var root = CreateTempDir();
        try
        {
            var patches = Path.Combine(root, "patches");
            Directory.CreateDirectory(patches);

            Directory.CreateDirectory(Path.Combine(patches, "1"));
            Directory.CreateDirectory(Path.Combine(patches, "2"));
            Directory.CreateDirectory(Path.Combine(patches, "3"));
            Directory.CreateDirectory(Path.Combine(patches, "4"));
            await File.WriteAllTextAsync(Path.Combine(patches, "2", "a.sql"), "SELECT 1;");
            await File.WriteAllTextAsync(Path.Combine(patches, "3", "b.sql"), "SELECT 1;");

            var json = """
                       {
                         "versions": [
                           { "id": "1", "name": "1", "upgradesTo": null, "order": 1 },
                           { "id": "2", "name": "2", "upgradesTo": null, "order": 2 },
                           { "id": "3", "name": "3", "upgradesTo": null, "order": 3 },
                           { "id": "4", "name": "4", "upgradesTo": null, "order": 4 }
                         ],
                         "patches": [
                           { "from": "1", "to": "2", "scripts": ["2/a.sql"] },
                           { "from": "2", "to": "3", "scripts": ["3/b.sql"] }
                         ]
                       }
                       """;
            await File.WriteAllTextAsync(Path.Combine(patches, "versions.json"), json);

            var svc = new VersionService(patches);
            await svc.LoadVersionsAsync();

            var targets = svc.GetTargetVersions("1").Select(v => v.Id).ToList();

            Assert.Contains("2", targets);
            Assert.Contains("3", targets);
            Assert.DoesNotContain("4", targets);
        }
        finally
        {
            TryDelete(root);
        }
    }

    [Fact]
    public async Task CalculateUpgradePath_ThrowsWhenNoPathExists()
    {
        var root = CreateTempDir();
        try
        {
            var patches = Path.Combine(root, "patches");
            Directory.CreateDirectory(patches);

            Directory.CreateDirectory(Path.Combine(patches, "1"));
            Directory.CreateDirectory(Path.Combine(patches, "2"));
            Directory.CreateDirectory(Path.Combine(patches, "4"));
            await File.WriteAllTextAsync(Path.Combine(patches, "2", "a.sql"), "SELECT 1;");

            var json = """
                       {
                         "versions": [
                           { "id": "1", "name": "1", "upgradesTo": null, "order": 1 },
                           { "id": "2", "name": "2", "upgradesTo": null, "order": 2 },
                           { "id": "4", "name": "4", "upgradesTo": null, "order": 4 }
                         ],
                         "patches": [
                           { "from": "1", "to": "2", "scripts": ["2/a.sql"] }
                         ]
                       }
                       """;
            await File.WriteAllTextAsync(Path.Combine(patches, "versions.json"), json);

            var svc = new VersionService(patches);
            await svc.LoadVersionsAsync();

            Assert.Throws<InvalidOperationException>(() => svc.CalculateUpgradePath("1", "4"));
        }
        finally
        {
            TryDelete(root);
        }
    }

    [Fact]
    public async Task CalculateUpgradePath_ThrowsWhenPatchHasNoScripts()
    {
        var root = CreateTempDir();
        try
        {
            var patches = Path.Combine(root, "patches");
            Directory.CreateDirectory(patches);

            Directory.CreateDirectory(Path.Combine(patches, "1"));
            Directory.CreateDirectory(Path.Combine(patches, "2"));

            var json = """
                       {
                         "versions": [
                           { "id": "1", "name": "1", "upgradesTo": null, "order": 1 },
                           { "id": "2", "name": "2", "upgradesTo": null, "order": 2 }
                         ],
                         "patches": [
                           { "from": "1", "to": "2", "scripts": [] }
                         ]
                       }
                       """;
            await File.WriteAllTextAsync(Path.Combine(patches, "versions.json"), json);

            var svc = new VersionService(patches);
            await svc.LoadVersionsAsync();

            Assert.Throws<InvalidOperationException>(() => svc.CalculateUpgradePath("1", "2"));
        }
        finally
        {
            TryDelete(root);
        }
    }

    [Fact]
    public async Task LoadVersionsAsync_NormalizesBackslashesToForwardSlashes()
    {
        var root = CreateTempDir();
        try
        {
            var patches = Path.Combine(root, "patches");
            Directory.CreateDirectory(patches);

            Directory.CreateDirectory(Path.Combine(patches, "1"));
            Directory.CreateDirectory(Path.Combine(patches, "2"));
            await File.WriteAllTextAsync(Path.Combine(patches, "2", "a.sql"), "SELECT 1;");

            var json = """
                       {
                         "versions": [
                           { "id": "1", "name": "1", "upgradesTo": null, "order": 1 },
                           { "id": "2", "name": "2", "upgradesTo": null, "order": 2 }
                         ],
                         "patches": [
                           { "from": "1", "to": "2", "scripts": ["2\\a.sql"] }
                         ]
                       }
                       """;
            await File.WriteAllTextAsync(Path.Combine(patches, "versions.json"), json);

            var svc = new VersionService(patches);
            await svc.LoadVersionsAsync();

            var patch = svc.GetAllPatches().Single();
            Assert.Contains("2/a.sql", patch.Scripts);
        }
        finally
        {
            TryDelete(root);
        }
    }

    [Fact]
    public async Task CalculateUpgradePath_RejectsScriptPathOutsidePatchesFolder()
    {
        var root = CreateTempDir();
        try
        {
            var patches = Path.Combine(root, "patches");
            Directory.CreateDirectory(patches);

            Directory.CreateDirectory(Path.Combine(patches, "1"));
            Directory.CreateDirectory(Path.Combine(patches, "2"));
            await File.WriteAllTextAsync(Path.Combine(root, "outside.sql"), "SELECT 1;");

            var json = """
                       {
                         "versions": [
                           { "id": "1", "name": "1", "upgradesTo": null, "order": 1 },
                           { "id": "2", "name": "2", "upgradesTo": null, "order": 2 }
                         ],
                         "patches": [
                           { "from": "1", "to": "2", "scripts": ["../outside.sql"] }
                         ]
                       }
                       """;
            await File.WriteAllTextAsync(Path.Combine(patches, "versions.json"), json);

            var svc = new VersionService(patches);
            await svc.LoadVersionsAsync();

            var ex = Assert.Throws<InvalidOperationException>(() => svc.CalculateUpgradePath("1", "2"));
            Assert.Contains("escapes patches folder", ex.Message, StringComparison.OrdinalIgnoreCase);
        }
        finally
        {
            TryDelete(root);
        }
    }

    [Fact]
    public async Task SyncWithFolders_AutoLinksNewVersionToTail()
    {
        var root = CreateTempDir();
        try
        {
            var patches = Path.Combine(root, "patches");
            Directory.CreateDirectory(patches);

            Directory.CreateDirectory(Path.Combine(patches, "7.2.3-20251231"));
            Directory.CreateDirectory(Path.Combine(patches, "7.2.3-20260123"));
            await File.WriteAllTextAsync(Path.Combine(patches, "7.2.3-20260123", "a.sql"), "SELECT 1;");

            var json = """
                       {
                         "versions": [
                           { "id": "7.2.3-20251231", "name": "7.2.3-20251231", "upgradesTo": null, "order": 1 }
                         ],
                         "patches": []
                       }
                       """;
            await File.WriteAllTextAsync(Path.Combine(patches, "versions.json"), json);

            var svc = new VersionService(patches);
            await svc.LoadVersionsAsync();

            var tail = svc.GetAllVersions().Single(v => v.Id == "7.2.3-20251231");
            Assert.Equal("7.2.3-20260123", tail.UpgradesTo);
        }
        finally
        {
            TryDelete(root);
        }
    }

    [Fact]
    public async Task AutoGeneratePatches_CreatesChainPatchFromUpgradesTo()
    {
        var root = CreateTempDir();
        try
        {
            var patches = Path.Combine(root, "patches");
            Directory.CreateDirectory(patches);

            Directory.CreateDirectory(Path.Combine(patches, "1"));
            Directory.CreateDirectory(Path.Combine(patches, "2"));
            await File.WriteAllTextAsync(Path.Combine(patches, "2", "a.sql"), "SELECT 1;");

            var json = """
                       {
                         "versions": [
                           { "id": "1", "name": "1", "upgradesTo": "2", "order": 1 },
                           { "id": "2", "name": "2", "upgradesTo": null, "order": 2 }
                         ],
                         "patches": []
                       }
                       """;
            await File.WriteAllTextAsync(Path.Combine(patches, "versions.json"), json);

            var svc = new VersionService(patches);
            await svc.LoadVersionsAsync();

            var patch = svc.GetAllPatches().Single(p => p.From == "1" && p.To == "2");
            Assert.True(patch.AutoGenerated);
            Assert.Contains("2/a.sql", patch.Scripts);
        }
        finally
        {
            TryDelete(root);
        }
    }

    [Fact]
    public async Task AutoGeneratePatches_CreatesDirectJumpForStableToBuild7x()
    {
        var root = CreateTempDir();
        try
        {
            var patches = Path.Combine(root, "patches");
            Directory.CreateDirectory(patches);

            Directory.CreateDirectory(Path.Combine(patches, "7.2.3-20260123"));
            await File.WriteAllTextAsync(Path.Combine(patches, "7.2.3-20260123", "a.sql"), "SELECT 1;");

            var json = """
                       {
                         "versions": [
                           { "id": "7.0", "name": "7.0", "upgradesTo": null, "order": 1 },
                           { "id": "7.2", "name": "7.2", "upgradesTo": null, "order": 2 },
                           { "id": "7.2.1", "name": "7.2.1", "upgradesTo": null, "order": 3 },
                           { "id": "7.2.3-20260123", "name": "7.2.3-20260123", "upgradesTo": null, "order": 4 }
                         ],
                         "patches": []
                       }
                       """;
            await File.WriteAllTextAsync(Path.Combine(patches, "versions.json"), json);

            var svc = new VersionService(patches);
            await svc.LoadVersionsAsync();

            Assert.Contains(svc.GetAllPatches(), p => p.From == "7.0" && p.To == "7.2.3-20260123");
            Assert.Contains(svc.GetAllPatches(), p => p.From == "7.2" && p.To == "7.2.3-20260123");
            Assert.Contains(svc.GetAllPatches(), p => p.From == "7.2.1" && p.To == "7.2.3-20260123");
        }
        finally
        {
            TryDelete(root);
        }
    }

    [Fact]
    public async Task AutoGeneratePatches_DoesNotOverrideManualPatch()
    {
        var root = CreateTempDir();
        try
        {
            var patches = Path.Combine(root, "patches");
            Directory.CreateDirectory(patches);

            Directory.CreateDirectory(Path.Combine(patches, "7.2.3-20260123"));
            await File.WriteAllTextAsync(Path.Combine(patches, "7.2.3-20260123", "a.sql"), "SELECT 1;");
            await File.WriteAllTextAsync(Path.Combine(patches, "7.2.3-20260123", "custom.sql"), "SELECT 2;");

            var json = """
                       {
                         "versions": [
                           { "id": "7.0", "name": "7.0", "upgradesTo": null, "order": 1 },
                           { "id": "7.2.3-20260123", "name": "7.2.3-20260123", "upgradesTo": null, "order": 2 }
                         ],
                         "patches": [
                           { "from": "7.0", "to": "7.2.3-20260123", "scripts": ["7.2.3-20260123/custom.sql"], "autoGenerated": false }
                         ]
                       }
                       """;
            await File.WriteAllTextAsync(Path.Combine(patches, "versions.json"), json);

            var svc = new VersionService(patches);
            await svc.LoadVersionsAsync();

            var patch = svc.GetAllPatches().Single(p => p.From == "7.0" && p.To == "7.2.3-20260123");
            Assert.False(patch.AutoGenerated);
            Assert.Single(patch.Scripts);
            Assert.Contains("7.2.3-20260123/custom.sql", patch.Scripts);
        }
        finally
        {
            TryDelete(root);
        }
    }

    [Fact]
    public async Task RemoveScriptFromVersion_RecordsNonFatalDiagnostic_WhenDeleteFails()
    {
        var root = CreateTempDir();
        try
        {
            var patches = Path.Combine(root, "patches");
            Directory.CreateDirectory(patches);
            Directory.CreateDirectory(Path.Combine(patches, "2.0"));

            var scriptPath = Path.Combine(patches, "2.0", "locked.sql");
            await File.WriteAllTextAsync(scriptPath, "SELECT 1;");

            var json = """
                       {
                         "versions": [
                           { "id": "1.0", "name": "1.0", "upgradesTo": null, "order": 1 },
                           { "id": "2.0", "name": "2.0", "upgradesTo": null, "order": 2 }
                         ],
                         "patches": [
                           { "from": "1.0", "to": "2.0", "scripts": ["2.0/locked.sql"] }
                         ]
                       }
                       """;
            await File.WriteAllTextAsync(Path.Combine(patches, "versions.json"), json);

            var svc = new VersionService(patches);
            await svc.LoadVersionsAsync();

            using var lockStream = new FileStream(scriptPath, FileMode.Open, FileAccess.Read, FileShare.None);
            await svc.RemoveScriptFromVersionAsync("2.0", "locked.sql");

            Assert.NotEmpty(svc.NonFatalDiagnostics);
            Assert.Contains("DeleteScriptFile", svc.NonFatalDiagnostics.Last(), StringComparison.OrdinalIgnoreCase);
        }
        finally
        {
            TryDelete(root);
        }
    }

    [Fact]
    public async Task AutoGeneratePatches_ForSixFivePlus_CreatesDirectToLatestAndOneStepPath()
    {
        var root = CreateTempDir();
        try
        {
            var patches = Path.Combine(root, "patches");
            Directory.CreateDirectory(patches);

            Directory.CreateDirectory(Path.Combine(patches, "7.2.3-20251117"));
            Directory.CreateDirectory(Path.Combine(patches, "7.2.3-20251205"));
            Directory.CreateDirectory(Path.Combine(patches, "7.2.3-20251231"));
            await File.WriteAllTextAsync(Path.Combine(patches, "7.2.3-20251205", "mid.sql"), "SELECT 1;");
            await File.WriteAllTextAsync(Path.Combine(patches, "7.2.3-20251231", "latest.sql"), "SELECT 2;");

            var json = """
                       {
                         "versions": [
                           { "id": "7.2.3-20251117", "name": "7.2.3-20251117", "upgradesTo": "7.2.3-20251205", "order": 1 },
                           { "id": "7.2.3-20251205", "name": "7.2.3-20251205", "upgradesTo": "7.2.3-20251231", "order": 2 },
                           { "id": "7.2.3-20251231", "name": "7.2.3-20251231", "upgradesTo": null, "order": 3 }
                         ],
                         "patches": []
                       }
                       """;
            await File.WriteAllTextAsync(Path.Combine(patches, "versions.json"), json);

            var svc = new VersionService(patches);
            await svc.LoadVersionsAsync();

            Assert.Contains(svc.GetAllPatches(), p =>
                p.From == "7.2.3-20251117" &&
                p.To == "7.2.3-20251231" &&
                p.AutoGenerated);

            var steps = svc.CalculateUpgradePath("7.2.3-20251117", "7.2.3-20251231");
            Assert.Single(steps);
            Assert.Equal("7.2.3-20251117", steps[0].FromVersion);
            Assert.Equal("7.2.3-20251231", steps[0].ToVersion);
        }
        finally
        {
            TryDelete(root);
        }
    }

    [Fact]
    public async Task AutoGeneratePatches_ForSixFivePlus_UsesOneStepForDesignatedIntermediateTarget()
    {
        var root = CreateTempDir();
        try
        {
            var patches = Path.Combine(root, "patches");
            Directory.CreateDirectory(patches);

            Directory.CreateDirectory(Path.Combine(patches, "7.2.3-20251117"));
            Directory.CreateDirectory(Path.Combine(patches, "7.2.3-20251205"));
            Directory.CreateDirectory(Path.Combine(patches, "7.2.3-20251231"));
            Directory.CreateDirectory(Path.Combine(patches, "7.2.3-20260123"));
            await File.WriteAllTextAsync(Path.Combine(patches, "7.2.3-20251205", "mid.sql"), "SELECT 1;");
            await File.WriteAllTextAsync(Path.Combine(patches, "7.2.3-20251231", "target.sql"), "SELECT 2;");
            await File.WriteAllTextAsync(Path.Combine(patches, "7.2.3-20260123", "latest.sql"), "SELECT 3;");

            var json = """
                       {
                         "versions": [
                           { "id": "7.2.3-20251117", "name": "7.2.3-20251117", "upgradesTo": "7.2.3-20251205", "order": 1 },
                           { "id": "7.2.3-20251205", "name": "7.2.3-20251205", "upgradesTo": "7.2.3-20251231", "order": 2 },
                           { "id": "7.2.3-20251231", "name": "7.2.3-20251231", "upgradesTo": "7.2.3-20260123", "order": 3 },
                           { "id": "7.2.3-20260123", "name": "7.2.3-20260123", "upgradesTo": null, "order": 4 }
                         ],
                         "patches": []
                       }
                       """;
            await File.WriteAllTextAsync(Path.Combine(patches, "versions.json"), json);

            var svc = new VersionService(patches);
            await svc.LoadVersionsAsync();

            var steps = svc.CalculateUpgradePath("7.2.3-20251117", "7.2.3-20251231");
            Assert.Single(steps);
            Assert.Equal("7.2.3-20251117", steps[0].FromVersion);
            Assert.Equal("7.2.3-20251231", steps[0].ToVersion);
        }
        finally
        {
            TryDelete(root);
        }
    }

    [Fact]
    public async Task LoadVersionsAsync_AddsNewStableVersionAfterBuildAndCreatesOneStepPatch()
    {
        var root = CreateTempDir();
        try
        {
            var patches = Path.Combine(root, "patches");
            Directory.CreateDirectory(patches);

            Directory.CreateDirectory(Path.Combine(patches, "7.2.3-20260123"));
            Directory.CreateDirectory(Path.Combine(patches, "7.2.4"));
            await File.WriteAllTextAsync(Path.Combine(patches, "7.2.3-20260123", "base.sql"), "SELECT 1;");
            await File.WriteAllTextAsync(Path.Combine(patches, "7.2.4", "7_2_3_patch.sql"), "SELECT 2;");
            await File.WriteAllTextAsync(Path.Combine(patches, "7.2.4", "7_2_3_Languages.sql"), "SELECT 3;");
            await File.WriteAllTextAsync(Path.Combine(patches, "7.2.4", "7_2_4.sql"), "SELECT 4;");

            var json = """
                       {
                         "versions": [
                           { "id": "7.2.3-20260123", "name": "7.2.3-20260123", "upgradesTo": null, "order": 1 }
                         ],
                         "patches": []
                       }
                       """;
            await File.WriteAllTextAsync(Path.Combine(patches, "versions.json"), json);

            var svc = new VersionService(patches);
            await svc.LoadVersionsAsync();

            var prior = svc.GetAllVersions().Single(v => v.Id == "7.2.3-20260123");
            var latest = svc.GetAllVersions().Single(v => v.Id == "7.2.4");
            Assert.Equal("7.2.4", prior.UpgradesTo);
            Assert.True(latest.Order > prior.Order);

            var patch = svc.GetAllPatches().Single(p => p.From == "7.2.3-20260123" && p.To == "7.2.4");
            Assert.True(patch.AutoGenerated);
            Assert.Equal(
                new[] { "7.2.4/7_2_3_Languages.sql", "7.2.4/7_2_3_patch.sql", "7.2.4/7_2_4.sql" },
                patch.Scripts.OrderBy(s => s, StringComparer.OrdinalIgnoreCase).ToArray());
        }
        finally
        {
            TryDelete(root);
        }
    }

    [Fact]
    public async Task RepoPatchLibrary_IncludesLegacyDirectTargets_AndFiveThreeThreeRerunFlow()
    {
        var svc = new VersionService(GetRepoPatchesPath());
        await svc.LoadVersionsAsync();

        Assert.False(svc.LastValidationResult.HasErrors, string.Join(Environment.NewLine, svc.LastValidationResult.Errors.Select(e => e.Message)));

        Assert.Contains(svc.GetAllVersions(), v => v.Id == "1.90");
        Assert.Contains(svc.GetAllVersions(), v => v.Id == "4.93");
        Assert.Contains(svc.GetAllVersions(), v => v.Id == "5.2.1");
        Assert.Contains(svc.GetAllVersions(), v => v.Id == "5.3.2");
        Assert.Contains(svc.GetSourceVersions(), v => v.Id == "4.52");

        var steppedLegacyPatch = svc.GetAllPatches().Single(p => p.From == "4.22" && p.To == "4.30");
        Assert.Equal(new[] { "4.30/SQL_Upgrade4_30from2_10.sql" }, steppedLegacyPatch.Scripts);

        var rerunPatch = svc.GetAllPatches().Single(p => p.From == "5.3.2" && p.To == "5.3.3");
        Assert.Equal(
            new[]
            {
                "5.3.3/Update_5_3_2.sql",
                "5.3.3/Update_5_3_2yearlyshift.sql",
                "5.3.3/Update_5_3_3_20181016.sql"
            },
            rerunPatch.Scripts);

        var steps = svc.CalculateUpgradePath("4.40", "5.3.3");
        Assert.Equal(
            new[] { "4.40", "4.52", "4.62", "4.70", "4.80", "4.81", "4.91", "4.92", "4.93", "5.2.1", "5.3.2", "5.3.3" },
            new[] { steps[0].FromVersion }.Concat(steps.Select(s => s.ToVersion)).ToArray());
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
