using MagDbPatcher.Models;

namespace MagDbPatcher.Services;

public interface IPatchCatalogService
{
    Task<PatchCatalogSnapshot> LoadAsync(string rootPath);
    Task<PatchCatalogSnapshot> ScanAsync(string rootPath);
    Task<PatchCatalogSnapshot> ApplyAsync(string rootPath, PatchCatalogMutation mutation);
    Task<ConfigValidationResult> ValidateAsync(string rootPath);
}
