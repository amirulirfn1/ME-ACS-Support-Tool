using System.IO;
using MagDbPatcher.Models;

namespace MagDbPatcher.Services;

internal sealed class PatchCatalogLoader
{
    public async Task<PatchCatalogSnapshot> LoadAsync(string rootPath)
    {
        var normalized = Path.GetFullPath(rootPath.Trim());
        var versionService = new VersionService(normalized);
        await versionService.LoadVersionsAsync();

        return new PatchCatalogSnapshot
        {
            RootPath = normalized,
            Versions = versionService.GetAllVersions(),
            Patches = versionService.GetAllPatches()
                .OrderBy(p => p.From, StringComparer.OrdinalIgnoreCase)
                .ThenBy(p => p.To, StringComparer.OrdinalIgnoreCase)
                .ToList(),
            AvailableScripts = versionService.GetAvailableScripts()
                .OrderBy(s => s, StringComparer.OrdinalIgnoreCase)
                .ToList(),
            Validation = versionService.LastValidationResult,
            Diagnostics = versionService.NonFatalDiagnostics.ToList()
        };
    }
}
