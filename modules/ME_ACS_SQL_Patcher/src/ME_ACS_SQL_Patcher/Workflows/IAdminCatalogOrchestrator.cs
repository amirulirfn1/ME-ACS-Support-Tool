using MagDbPatcher.Models;

namespace MagDbPatcher.Workflows;

public interface IAdminCatalogOrchestrator
{
    Task<PatchCatalogSnapshot> ScanAsync(string rootPath);
    Task<PatchCatalogSnapshot> ApplyAsync(string rootPath, PatchCatalogMutation mutation);
    Task<ConfigValidationResult> ValidateAsync(string rootPath);
}
