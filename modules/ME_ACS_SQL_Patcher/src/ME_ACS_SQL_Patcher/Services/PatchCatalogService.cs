using MagDbPatcher.Models;

namespace MagDbPatcher.Services;

public sealed class PatchCatalogService : IPatchCatalogService
{
    private readonly PatchCatalogLoader _loader = new();
    private readonly PatchCatalogValidator _validator = new();
    private readonly PatchCatalogMutator _mutator = new();

    public Task<PatchCatalogSnapshot> LoadAsync(string rootPath) => _loader.LoadAsync(rootPath);

    public async Task<PatchCatalogSnapshot> ScanAsync(string rootPath)
    {
        var snapshot = await _loader.LoadAsync(rootPath);
        var diagnostics = snapshot.Diagnostics.ToList();
        diagnostics.Add($"[{DateTime.UtcNow:O}] Scan completed for '{snapshot.RootPath}'.");

        return new PatchCatalogSnapshot
        {
            RootPath = snapshot.RootPath,
            Versions = snapshot.Versions,
            Patches = snapshot.Patches,
            AvailableScripts = snapshot.AvailableScripts,
            Validation = snapshot.Validation,
            Diagnostics = diagnostics
        };
    }

    public async Task<PatchCatalogSnapshot> ApplyAsync(string rootPath, PatchCatalogMutation mutation)
    {
        await _mutator.ApplyAsync(rootPath, mutation);

        var snapshot = await _loader.LoadAsync(rootPath);
        var diagnostics = snapshot.Diagnostics.ToList();
        diagnostics.Add($"[{DateTime.UtcNow:O}] Applied catalog mutation: {mutation.Versions.Count} version change(s), {mutation.PatchLinks.Count} patch link change(s).");

        return new PatchCatalogSnapshot
        {
            RootPath = snapshot.RootPath,
            Versions = snapshot.Versions,
            Patches = snapshot.Patches,
            AvailableScripts = snapshot.AvailableScripts,
            Validation = snapshot.Validation,
            Diagnostics = diagnostics
        };
    }

    public Task<ConfigValidationResult> ValidateAsync(string rootPath) => _validator.ValidateAsync(rootPath);
}
