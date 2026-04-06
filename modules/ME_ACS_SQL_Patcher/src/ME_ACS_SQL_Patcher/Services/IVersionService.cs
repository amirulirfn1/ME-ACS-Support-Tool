using MagDbPatcher.Models;

namespace MagDbPatcher.Services;

public interface IVersionService
{
    ConfigValidationResult LastValidationResult { get; }
    IReadOnlyList<string> NonFatalDiagnostics { get; }

    Task LoadVersionsAsync();
    List<VersionInfo> GetAllVersions();
    List<VersionInfo> GetSourceVersions();
    List<VersionInfo> GetTargetVersions(string fromVersionId);
    List<PatchStep> CalculateUpgradePath(string fromVersionId, string toVersionId);
    List<PatchInfo> GetAllPatches();
    string GetPatchesFolder();
    int GetScriptCount(string versionId);
    List<string> GetScriptsForVersion(string versionId);
    List<string> GetAvailableScripts();

    Task AddVersionAsync(string id, string name, string? upgradesTo);
    Task UpdateVersionAsync(string id, string name, string? upgradesTo);
    Task DeleteVersionAsync(string id);
    Task AddPatchAsync(string from, string to);
    Task UpdatePatchAsync(string oldFrom, string oldTo, string newFrom, string newTo);
    Task DeletePatchAsync(string from, string to);
    Task UpdatePatchScriptsAsync(string from, string to, List<string> scripts);
    Task MarkPatchManualAsync(string from, string to);
    Task AddScriptToVersionAsync(string versionId, string scriptSourcePath);
    Task RemoveScriptFromVersionAsync(string versionId, string scriptName);
}
