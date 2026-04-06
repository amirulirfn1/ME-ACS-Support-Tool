using System;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using MagDbPatcher.Infrastructure;
using MagDbPatcher.Models;

namespace MagDbPatcher.Services;

public class PatchStorageService : IPatchStorageService
{
    private readonly AppRuntimePaths _appPaths;

    public PatchStorageService(AppRuntimePaths? appPaths = null)
    {
        _appPaths = appPaths ?? AppRuntimePaths.CreateDefault();
    }

    public string GetDefaultPatchesFolder() => _appPaths.PatchesFolder;

    public string GetDefaultTempFolder() => _appPaths.TempFolder;

    public async Task<string> ResolvePatchesFolderAsync(AppSettings settings, string bundledPatchesFolder)
    {
        if (!string.IsNullOrWhiteSpace(settings.PatchesFolder))
        {
            var configured = Path.GetFullPath(settings.PatchesFolder);
            if (!IsLegacyBundledFolder(configured))
                return configured;
        }

        var managedPatchesFolder = GetDefaultPatchesFolder();
        await EnsureSeededAsync(managedPatchesFolder, bundledPatchesFolder);
        settings.PatchesFolder = managedPatchesFolder;
        return managedPatchesFolder;
    }

    public async Task EnsureSeededAsync(string targetPatchesFolder, string bundledPatchesFolder)
    {
        Directory.CreateDirectory(targetPatchesFolder);

        if (string.Equals(
                Path.GetFullPath(targetPatchesFolder),
                Path.GetFullPath(bundledPatchesFolder),
                StringComparison.OrdinalIgnoreCase))
        {
            return;
        }

        if (Directory.EnumerateFileSystemEntries(targetPatchesFolder).Any())
            return;

        if (!Directory.Exists(bundledPatchesFolder))
            return;

        await Task.Run(() => CopyDirectory(bundledPatchesFolder, targetPatchesFolder));
    }

    public async Task ResetToBundledAsync(string targetPatchesFolder, string bundledPatchesFolder)
    {
        Directory.CreateDirectory(targetPatchesFolder);

        if (string.Equals(
                Path.GetFullPath(targetPatchesFolder),
                Path.GetFullPath(bundledPatchesFolder),
                StringComparison.OrdinalIgnoreCase))
        {
            return;
        }

        if (!Directory.Exists(bundledPatchesFolder))
            return;

        await Task.Run(() =>
        {
            ClearDirectory(targetPatchesFolder);
            CopyDirectory(bundledPatchesFolder, targetPatchesFolder);
        });
    }

    public async Task<bool> RefreshManagedLibraryFromBundledIfSafeAsync(
        string targetPatchesFolder,
        string bundledPatchesFolder,
        bool hasImportedPack,
        string? bundledCatalogHash = null)
    {
        if (hasImportedPack)
            return false;

        Directory.CreateDirectory(targetPatchesFolder);

        if (string.Equals(
                Path.GetFullPath(targetPatchesFolder),
                Path.GetFullPath(bundledPatchesFolder),
                StringComparison.OrdinalIgnoreCase))
        {
            return false;
        }

        if (!Directory.Exists(bundledPatchesFolder))
            return false;

        if (!Directory.EnumerateFileSystemEntries(targetPatchesFolder).Any())
        {
            await EnsureSeededAsync(targetPatchesFolder, bundledPatchesFolder);
            return true;
        }

        var targetHash = PatchCatalogDescriptorBuilder.ComputeFolderHash(targetPatchesFolder);
        var expectedHash = string.IsNullOrWhiteSpace(bundledCatalogHash)
            ? PatchCatalogDescriptorBuilder.ComputeFolderHash(bundledPatchesFolder)
            : bundledCatalogHash.Trim();

        if (string.Equals(targetHash, expectedHash, StringComparison.OrdinalIgnoreCase))
            return false;

        await ResetToBundledAsync(targetPatchesFolder, bundledPatchesFolder);
        return true;
    }

    private bool IsLegacyBundledFolder(string configuredFolder)
    {
        return string.Equals(configuredFolder, Path.GetFullPath(_appPaths.BundledPatchesFolder), StringComparison.OrdinalIgnoreCase) ||
               string.Equals(configuredFolder, Path.GetFullPath(_appPaths.LegacyPortablePatchesFolder), StringComparison.OrdinalIgnoreCase);
    }

    private static void CopyDirectory(string source, string destination)
    {
        Directory.CreateDirectory(destination);

        foreach (var dir in Directory.GetDirectories(source, "*", SearchOption.AllDirectories))
        {
            var relative = Path.GetRelativePath(source, dir);
            Directory.CreateDirectory(Path.Combine(destination, relative));
        }

        foreach (var file in Directory.GetFiles(source, "*", SearchOption.AllDirectories))
        {
            var relative = Path.GetRelativePath(source, file);
            var destinationFile = Path.Combine(destination, relative);
            var destinationDir = Path.GetDirectoryName(destinationFile);
            if (!string.IsNullOrWhiteSpace(destinationDir))
                Directory.CreateDirectory(destinationDir);

            File.Copy(file, destinationFile, overwrite: true);
        }
    }

    private static void ClearDirectory(string directory)
    {
        if (!Directory.Exists(directory))
            return;

        foreach (var file in Directory.GetFiles(directory))
            File.Delete(file);

        foreach (var child in Directory.GetDirectories(directory))
            Directory.Delete(child, recursive: true);
    }
}
