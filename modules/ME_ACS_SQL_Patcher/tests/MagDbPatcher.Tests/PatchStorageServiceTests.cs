using MagDbPatcher.Models;
using MagDbPatcher.Infrastructure;
using MagDbPatcher.Services;
using Xunit;

namespace MagDbPatcher.Tests;

public class PatchStorageServiceTests
{
    [Fact]
    public async Task EnsureSeededAsync_CopiesBundledPatches_WhenTargetEmpty()
    {
        var root = Path.Combine(Path.GetTempPath(), "MagDbPatcher.Tests", Guid.NewGuid().ToString("N"));
        Directory.CreateDirectory(root);

        var bundled = Path.Combine(root, "bundled");
        var target = Path.Combine(root, "target");
        Directory.CreateDirectory(Path.Combine(bundled, "7.0"));
        await File.WriteAllTextAsync(Path.Combine(bundled, "versions.json"), """{ "versions": [], "patches": [] }""");
        await File.WriteAllTextAsync(Path.Combine(bundled, "7.0", "script.sql"), "SELECT 1;");

        var service = new PatchStorageService();
        await service.EnsureSeededAsync(target, bundled);

        Assert.True(File.Exists(Path.Combine(target, "versions.json")));
        Assert.True(File.Exists(Path.Combine(target, "7.0", "script.sql")));
    }

    [Fact]
    public async Task ResolvePatchesFolderAsync_UsesConfiguredFolder_WithoutOverriding()
    {
        var root = Path.Combine(Path.GetTempPath(), "MagDbPatcher.Tests", Guid.NewGuid().ToString("N"));
        Directory.CreateDirectory(root);

        var configured = Path.Combine(root, "configured");
        Directory.CreateDirectory(configured);
        await File.WriteAllTextAsync(Path.Combine(configured, "keep.txt"), "1");

        var bundled = Path.Combine(root, "bundled");
        Directory.CreateDirectory(bundled);
        await File.WriteAllTextAsync(Path.Combine(bundled, "versions.json"), """{ "versions": [], "patches": [] }""");

        var settings = new AppSettings { PatchesFolder = configured };
        var service = new PatchStorageService();
        var resolved = await service.ResolvePatchesFolderAsync(settings, bundled);

        Assert.Equal(Path.GetFullPath(configured), resolved);
        Assert.True(File.Exists(Path.Combine(configured, "keep.txt")));
    }

    [Fact]
    public async Task ResolvePatchesFolderAsync_UsesManagedAppDataFolderByDefault()
    {
        var root = Path.Combine(Path.GetTempPath(), "MagDbPatcher.Tests", Guid.NewGuid().ToString("N"));
        Directory.CreateDirectory(root);

        var appPaths = TestAppPaths.Create(root);
        Directory.CreateDirectory(appPaths.BundledPatchesFolder);
        await File.WriteAllTextAsync(Path.Combine(appPaths.BundledPatchesFolder, "versions.json"), """{ "versions": [], "patches": [] }""");

        var settings = new AppSettings();
        var service = new PatchStorageService(appPaths);
        var resolved = await service.ResolvePatchesFolderAsync(settings, appPaths.BundledPatchesFolder);

        Assert.Equal(appPaths.PatchesFolder, resolved);
        Assert.Equal(appPaths.PatchesFolder, settings.PatchesFolder);
    }

    [Fact]
    public async Task ResetToBundledAsync_ReplacesExistingManagedLibrary()
    {
        var root = Path.Combine(Path.GetTempPath(), "MagDbPatcher.Tests", Guid.NewGuid().ToString("N"));
        Directory.CreateDirectory(root);

        var bundled = Path.Combine(root, "bundled");
        var target = Path.Combine(root, "target");
        Directory.CreateDirectory(Path.Combine(bundled, "6.5"));
        await File.WriteAllTextAsync(Path.Combine(bundled, "versions.json"), """{ "versions": [{ "id": "6.5", "name": "6.5", "upgradesTo": null, "order": 1 }], "patches": [] }""");
        await File.WriteAllTextAsync(Path.Combine(bundled, "6.5", "full.sql"), "SELECT 1;");

        Directory.CreateDirectory(Path.Combine(target, "7.0"));
        await File.WriteAllTextAsync(Path.Combine(target, "versions.json"), """{ "versions": [{ "id": "7.0", "name": "7.0", "upgradesTo": null, "order": 1 }], "patches": [] }""");
        await File.WriteAllTextAsync(Path.Combine(target, "7.0", "stale.sql"), "SELECT 7;");

        var service = new PatchStorageService();
        await service.ResetToBundledAsync(target, bundled);

        var versionsJson = await File.ReadAllTextAsync(Path.Combine(target, "versions.json"));
        Assert.Contains("\"id\": \"6.5\"", versionsJson);
        Assert.DoesNotContain("\"id\": \"7.0\"", versionsJson);
        Assert.True(File.Exists(Path.Combine(target, "6.5", "full.sql")));
        Assert.False(File.Exists(Path.Combine(target, "7.0", "stale.sql")));
    }

    [Fact]
    public async Task RefreshManagedLibraryFromBundledIfSafeAsync_RefreshesDefaultLibrary_WhenCatalogChanged()
    {
        var root = Path.Combine(Path.GetTempPath(), "MagDbPatcher.Tests", Guid.NewGuid().ToString("N"));
        Directory.CreateDirectory(root);

        var bundled = Path.Combine(root, "bundled");
        var target = Path.Combine(root, "target");
        Directory.CreateDirectory(Path.Combine(bundled, "7.2.4"));
        await File.WriteAllTextAsync(Path.Combine(bundled, "versions.json"), """{ "versions": [{ "id": "7.2.4", "name": "7.2.4", "upgradesTo": null, "order": 1 }], "patches": [] }""");
        await File.WriteAllTextAsync(Path.Combine(bundled, "7.2.4", "fresh.sql"), "SELECT 1;");

        Directory.CreateDirectory(Path.Combine(target, "7.2.3"));
        await File.WriteAllTextAsync(Path.Combine(target, "versions.json"), """{ "versions": [{ "id": "7.2.3", "name": "7.2.3", "upgradesTo": null, "order": 1 }], "patches": [] }""");
        await File.WriteAllTextAsync(Path.Combine(target, "7.2.3", "stale.sql"), "SELECT 0;");

        var service = new PatchStorageService();
        var refreshed = await service.RefreshManagedLibraryFromBundledIfSafeAsync(target, bundled, hasImportedPack: false);

        Assert.True(refreshed);
        Assert.True(File.Exists(Path.Combine(target, "7.2.4", "fresh.sql")));
        Assert.False(File.Exists(Path.Combine(target, "7.2.3", "stale.sql")));
    }

    [Fact]
    public async Task RefreshManagedLibraryFromBundledIfSafeAsync_SkipsRefresh_WhenImportedPackExists()
    {
        var root = Path.Combine(Path.GetTempPath(), "MagDbPatcher.Tests", Guid.NewGuid().ToString("N"));
        Directory.CreateDirectory(root);

        var bundled = Path.Combine(root, "bundled");
        var target = Path.Combine(root, "target");
        Directory.CreateDirectory(Path.Combine(bundled, "7.2.4"));
        await File.WriteAllTextAsync(Path.Combine(bundled, "versions.json"), """{ "versions": [{ "id": "7.2.4", "name": "7.2.4", "upgradesTo": null, "order": 1 }], "patches": [] }""");
        await File.WriteAllTextAsync(Path.Combine(bundled, "7.2.4", "fresh.sql"), "SELECT 1;");

        Directory.CreateDirectory(Path.Combine(target, "custom"));
        await File.WriteAllTextAsync(Path.Combine(target, "versions.json"), """{ "versions": [{ "id": "custom", "name": "custom", "upgradesTo": null, "order": 1 }], "patches": [] }""");
        await File.WriteAllTextAsync(Path.Combine(target, "custom", "keep.sql"), "SELECT 7;");

        var service = new PatchStorageService();
        var refreshed = await service.RefreshManagedLibraryFromBundledIfSafeAsync(target, bundled, hasImportedPack: true);

        Assert.False(refreshed);
        Assert.True(File.Exists(Path.Combine(target, "custom", "keep.sql")));
        Assert.False(File.Exists(Path.Combine(target, "7.2.4", "fresh.sql")));
    }
}
