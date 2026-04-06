using MagDbPatcher.Models;
using MagDbPatcher.Services;

namespace MagDbPatcher.Workflows;

public sealed class AdminCatalogOrchestrator : IAdminCatalogOrchestrator
{
    private readonly IPatchCatalogService _catalogService;

    public AdminCatalogOrchestrator(IPatchCatalogService? catalogService = null)
    {
        _catalogService = catalogService ?? new PatchCatalogService();
    }

    public Task<PatchCatalogSnapshot> ScanAsync(string rootPath) => _catalogService.ScanAsync(rootPath);

    public Task<PatchCatalogSnapshot> ApplyAsync(string rootPath, PatchCatalogMutation mutation)
        => _catalogService.ApplyAsync(rootPath, mutation);

    public Task<ConfigValidationResult> ValidateAsync(string rootPath) => _catalogService.ValidateAsync(rootPath);
}
