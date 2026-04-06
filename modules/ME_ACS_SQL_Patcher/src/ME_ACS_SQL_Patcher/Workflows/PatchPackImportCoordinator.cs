using MagDbPatcher.Models;
using MagDbPatcher.Services;

namespace MagDbPatcher.Workflows;

public sealed class PatchPackImportCoordinator
{
    private readonly PatchPackService _patchPackService;

    public PatchPackImportCoordinator(PatchPackService patchPackService)
    {
        _patchPackService = patchPackService;
    }

    public async Task<PatchImportResult> ImportAsync(PatchImportRequest request)
    {
        var result = await _patchPackService.ImportAsync(request.ZipPath, request.TargetPatchesFolder);
        var label = $"{result.Manifest.PackVersion} ({result.Manifest.ReleasedAt:yyyy-MM-dd})";

        return new PatchImportResult
        {
            BackupFolder = result.BackupFolder,
            PackLabel = label,
            ArchivedPackPath = result.ArchivedPackPath
        };
    }
}
