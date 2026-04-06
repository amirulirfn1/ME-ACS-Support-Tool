using MagDbPatcher.Models;

namespace MagDbPatcher.Services;

public interface IPatchStorageService
{
    string GetDefaultPatchesFolder();
    string GetDefaultTempFolder();
    Task<string> ResolvePatchesFolderAsync(AppSettings settings, string bundledPatchesFolder);
    Task EnsureSeededAsync(string targetPatchesFolder, string bundledPatchesFolder);
    Task ResetToBundledAsync(string targetPatchesFolder, string bundledPatchesFolder);
    Task<bool> RefreshManagedLibraryFromBundledIfSafeAsync(
        string targetPatchesFolder,
        string bundledPatchesFolder,
        bool hasImportedPack,
        string? bundledCatalogHash = null);
}
