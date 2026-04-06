using System.IO;
using MagDbPatcher.Models;

namespace MagDbPatcher.Services;

internal sealed class PatchCatalogValidator
{
    public async Task<ConfigValidationResult> ValidateAsync(string rootPath)
    {
        var versionService = new VersionService(Path.GetFullPath(rootPath.Trim()));
        await versionService.LoadVersionsAsync();
        return versionService.LastValidationResult;
    }
}
