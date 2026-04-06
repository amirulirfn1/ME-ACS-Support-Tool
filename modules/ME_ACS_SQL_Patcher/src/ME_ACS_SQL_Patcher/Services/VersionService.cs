using System.IO;
using MagDbPatcher.Models;

namespace MagDbPatcher.Services;

public class VersionService : IVersionService
{
    private VersionConfig _config = new();
    private PatcherConfig _patcherConfig = new();
    private readonly string _patchesFolder;
    private readonly string _patchesFolderRoot;
    private readonly string _configPath;
    private readonly string _patcherConfigPath;
    private readonly List<string> _nonFatalDiagnostics = new();
    private readonly VersionGraphService _versionGraphService = new();
    private readonly VersionConfigRepository _configRepository = new();
    private readonly PatchAutoGenerationService _patchAutoGenerationService = new();
    private readonly PatcherConfigService _patcherConfigService = new();
    private readonly VersionCatalogValidationService _validationService = new();
    private readonly VersionCatalogMaintenanceService _catalogMaintenanceService;

    public VersionService(string patchesFolder)
    {
        _patchesFolder = patchesFolder;
        _patchesFolderRoot = EnsureTrailingSeparator(Path.GetFullPath(_patchesFolder));
        _configPath = Path.Combine(_patchesFolder, "versions.json");
        _patcherConfigPath = Path.Combine(_patchesFolder, "patcher.config.json");
        _catalogMaintenanceService = new VersionCatalogMaintenanceService(_patchAutoGenerationService);
    }

    public ConfigValidationResult LastValidationResult { get; private set; } = new();
    public IReadOnlyList<string> NonFatalDiagnostics => _nonFatalDiagnostics;

    public async Task LoadVersionsAsync()
    {
        _nonFatalDiagnostics.Clear();
        _patcherConfig = await _patcherConfigService.LoadAsync(_patcherConfigPath, _configRepository);
        _config = await _configRepository.LoadAsync(_configPath);

        var changed = _catalogMaintenanceService.RunLoadPipeline(_config, _patcherConfig, _patchesFolder);
        LastValidationResult = _validationService.Validate(_config, NormalizeVersionId, NormalizeScriptPath, ToFullScriptPath);

        if (changed)
            await SaveConfigAsync();
    }

    private async Task SaveConfigAsync()
    {
        await _configRepository.SaveAsync(_configPath, _config);
    }

    public List<VersionInfo> GetAllVersions() =>
        _config.Versions
            .OrderBy(v => v.Order)
            .ThenBy(v => v.Id, StringComparer.OrdinalIgnoreCase)
            .ToList();

    public List<VersionInfo> GetSourceVersions()
        => _config.Versions
            .OrderBy(v => v.Order)
            .ThenBy(v => v.Id, StringComparer.OrdinalIgnoreCase)
            .ToList();

    public List<VersionInfo> GetTargetVersions(string fromVersionId)
    {
        var sourceVersion = _config.Versions.FirstOrDefault(v =>
            string.Equals(v.Id, NormalizeVersionId(fromVersionId), StringComparison.OrdinalIgnoreCase));
        if (sourceVersion == null) return new List<VersionInfo>();

        return GetReachableVersions(fromVersionId)
            .Where(v => v.Order > sourceVersion.Order)
            .OrderBy(v => v.Order)
            .ThenBy(v => v.Id, StringComparer.OrdinalIgnoreCase)
            .ToList();
    }

    public List<PatchStep> CalculateUpgradePath(string fromVersionId, string toVersionId)
    {
        fromVersionId = NormalizeVersionId(fromVersionId);
        toVersionId = NormalizeVersionId(toVersionId);

        if (string.Equals(fromVersionId, toVersionId, StringComparison.OrdinalIgnoreCase))
        {
            throw new InvalidOperationException("From and To versions cannot be the same.");
        }

        var versionsById = _config.Versions.ToDictionary(v => v.Id, v => v, StringComparer.OrdinalIgnoreCase);
        if (!versionsById.ContainsKey(fromVersionId))
            throw new InvalidOperationException($"Unknown source version '{fromVersionId}'.");
        if (!versionsById.ContainsKey(toVersionId))
            throw new InvalidOperationException($"Unknown target version '{toVersionId}'.");

        var adjacency = _versionGraphService.BuildAdjacencyList(_config.Patches, versionsById);
        if (!adjacency.ContainsKey(fromVersionId))
            throw new InvalidOperationException($"No patches found from source version '{fromVersionId}'.");
        var pathVersions = _versionGraphService.FindShortestPathBySteps(fromVersionId, toVersionId, adjacency);
        if (pathVersions.Count == 0)
            throw new InvalidOperationException($"No upgrade path from {fromVersionId} to {toVersionId}");

        // Convert to PatchSteps (edges)
        var steps = new List<PatchStep>();
        for (var i = 0; i < pathVersions.Count - 1; i++)
        {
            var from = pathVersions[i];
            var to = pathVersions[i + 1];
            var patch = _config.Patches.FirstOrDefault(p =>
                string.Equals(NormalizeVersionId(p.From), from, StringComparison.OrdinalIgnoreCase) &&
                string.Equals(NormalizeVersionId(p.To), to, StringComparison.OrdinalIgnoreCase));

            if (patch == null)
                throw new InvalidOperationException($"No patch definition found for {from} -> {to}.");

            var normalizedScripts = patch.Scripts
                .Select(NormalizeScriptPath)
                .Where(s => !string.IsNullOrWhiteSpace(s))
                .ToList();

            if (normalizedScripts.Count == 0)
                throw new InvalidOperationException($"Patch {from} -> {to} has no scripts configured.");

            var absoluteScripts = normalizedScripts.Select(script =>
            {
                var full = ToFullScriptPath(script);
                if (!File.Exists(full))
                    throw new InvalidOperationException($"Missing script file for patch {from} -> {to}: {script}");
                return full;
            }).ToList();

            steps.Add(new PatchStep
            {
                FromVersion = from,
                ToVersion = to,
                Scripts = absoluteScripts
            });
        }

        return steps;
    }

    public int GetScriptCount(string versionId)
    {
        // Count scripts in the version's folder
        var versionFolder = Path.Combine(_patchesFolder, versionId);
        if (!Directory.Exists(versionFolder)) return 0;
        return Directory.GetFiles(versionFolder, "*.sql").Length;
    }

    public List<string> GetScriptsForVersion(string versionId)
    {
        // Get scripts directly from the version's folder
        var versionFolder = Path.Combine(_patchesFolder, versionId);
        if (!Directory.Exists(versionFolder)) return new List<string>();
        return Directory.GetFiles(versionFolder, "*.sql")
            .Select(f => Path.GetFileName(f))
            .ToList();
    }

    // ========== VERSION MANAGEMENT ==========

    public async Task AddVersionAsync(string id, string name, string? upgradesTo)
    {
        id = NormalizeVersionId(id);
        name = name.Trim();
        upgradesTo = string.IsNullOrWhiteSpace(upgradesTo) ? null : NormalizeVersionId(upgradesTo);

        // Remove any existing version with same ID
        _config.Versions.RemoveAll(v => string.Equals(v.Id, id, StringComparison.OrdinalIgnoreCase));

        var nextOrder = _config.Versions.Any() ? _config.Versions.Max(v => v.Order) + 1 : 1;
        _config.Versions.Add(new VersionInfo
        {
            Id = id,
            Name = name,
            UpgradesTo = upgradesTo,
            Order = nextOrder
        });

        // Create folder for version
        var versionFolder = Path.Combine(_patchesFolder, id);
        if (!Directory.Exists(versionFolder))
            Directory.CreateDirectory(versionFolder);

        await SaveConfigAsync();
    }

    public async Task UpdateVersionAsync(string id, string name, string? upgradesTo)
    {
        id = NormalizeVersionId(id);
        name = name.Trim();
        upgradesTo = string.IsNullOrWhiteSpace(upgradesTo) ? null : NormalizeVersionId(upgradesTo);

        var version = _config.Versions.FirstOrDefault(v =>
            string.Equals(v.Id, id, StringComparison.OrdinalIgnoreCase));
        if (version != null)
        {
            version.Name = name;
            version.UpgradesTo = upgradesTo;
        }
        await SaveConfigAsync();
    }

    public async Task DeleteVersionAsync(string id)
    {
        id = NormalizeVersionId(id);

        _config.Versions.RemoveAll(v => string.Equals(v.Id, id, StringComparison.OrdinalIgnoreCase));
        _config.Patches.RemoveAll(p =>
            string.Equals(NormalizeVersionId(p.From), id, StringComparison.OrdinalIgnoreCase) ||
            string.Equals(NormalizeVersionId(p.To), id, StringComparison.OrdinalIgnoreCase));

        // Update any versions that pointed to this one
        foreach (var v in _config.Versions.Where(v =>
                     string.Equals(v.UpgradesTo, id, StringComparison.OrdinalIgnoreCase)))
        {
            v.UpgradesTo = null;
        }

        // Delete folder
        var versionFolder = Path.Combine(_patchesFolder, id);
        if (Directory.Exists(versionFolder))
        {
            try
            {
                Directory.Delete(versionFolder, true);
            }
            catch (Exception ex)
            {
                AddNonFatalDiagnostic("DeleteVersionFolder", versionFolder, ex);
            }
        }

        await SaveConfigAsync();
    }

    // ========== SCRIPT MANAGEMENT ==========

    public async Task AddScriptToVersionAsync(string versionId, string scriptSourcePath)
    {
        versionId = NormalizeVersionId(versionId);

        // Copy script to version folder
        var versionFolder = Path.Combine(_patchesFolder, versionId);
        if (!Directory.Exists(versionFolder))
            Directory.CreateDirectory(versionFolder);

        var scriptName = Path.GetFileName(scriptSourcePath);
        var destPath = Path.Combine(versionFolder, scriptName);
        File.Copy(scriptSourcePath, destPath, true);

        // If there's a single "previous" version by upgradesTo chain, attach script to that patch automatically.
        var previousVersion = _config.Versions.FirstOrDefault(v =>
            string.Equals(v.UpgradesTo, versionId, StringComparison.OrdinalIgnoreCase));

        if (previousVersion != null)
        {
            var patch = _config.Patches.FirstOrDefault(p =>
                string.Equals(NormalizeVersionId(p.From), previousVersion.Id, StringComparison.OrdinalIgnoreCase) &&
                string.Equals(NormalizeVersionId(p.To), versionId, StringComparison.OrdinalIgnoreCase));

            if (patch == null)
            {
                patch = new PatchInfo { From = previousVersion.Id, To = versionId, Scripts = new List<string>() };
                _config.Patches.Add(patch);
            }

            var relativePath = $"{versionId}/{scriptName}";
            if (!patch.Scripts.Any(s =>
                    string.Equals(NormalizeScriptPath(s), relativePath, StringComparison.OrdinalIgnoreCase)))
            {
                patch.Scripts.Add(relativePath);
            }
        }

        await SaveConfigAsync();
    }

    public async Task RemoveScriptFromVersionAsync(string versionId, string scriptName)
    {
        versionId = NormalizeVersionId(versionId);
        scriptName = scriptName.Trim();

        // Remove from patches that target this version
        foreach (var patch in _config.Patches.Where(p =>
                     string.Equals(NormalizeVersionId(p.To), versionId, StringComparison.OrdinalIgnoreCase)))
        {
            var relativePath = $"{versionId}/{scriptName}";
            patch.Scripts.RemoveAll(s =>
                string.Equals(NormalizeScriptPath(s), relativePath, StringComparison.OrdinalIgnoreCase));
            patch.Scripts.RemoveAll(s =>
                string.Equals(Path.GetFileName(s.Replace('/', Path.DirectorySeparatorChar)), scriptName,
                    StringComparison.OrdinalIgnoreCase));
        }

        // Delete file
        var scriptPath = Path.Combine(_patchesFolder, versionId, scriptName);
        if (File.Exists(scriptPath))
        {
            try
            {
                File.Delete(scriptPath);
            }
            catch (Exception ex)
            {
                AddNonFatalDiagnostic("DeleteScriptFile", scriptPath, ex);
            }
        }

        await SaveConfigAsync();
    }

    // ========== PATCH MANAGEMENT ==========

    public List<PatchInfo> GetAllPatches() => _config.Patches;

    public async Task AddPatchAsync(string from, string to)
    {
        from = NormalizeVersionId(from);
        to = NormalizeVersionId(to);

        if (_config.Patches.Any(p =>
                string.Equals(NormalizeVersionId(p.From), from, StringComparison.OrdinalIgnoreCase) &&
                string.Equals(NormalizeVersionId(p.To), to, StringComparison.OrdinalIgnoreCase)))
            return;

        _config.Patches.Add(new PatchInfo { From = from, To = to, Scripts = new List<string>() });
        await SaveConfigAsync();
    }

    public async Task UpdatePatchAsync(string oldFrom, string oldTo, string newFrom, string newTo)
    {
        oldFrom = NormalizeVersionId(oldFrom);
        oldTo = NormalizeVersionId(oldTo);
        newFrom = NormalizeVersionId(newFrom);
        newTo = NormalizeVersionId(newTo);

        var patch = _config.Patches.FirstOrDefault(p =>
            string.Equals(NormalizeVersionId(p.From), oldFrom, StringComparison.OrdinalIgnoreCase) &&
            string.Equals(NormalizeVersionId(p.To), oldTo, StringComparison.OrdinalIgnoreCase));
        if (patch != null)
        {
            patch.From = newFrom;
            patch.To = newTo;
        }
        await SaveConfigAsync();
    }

    public async Task DeletePatchAsync(string from, string to)
    {
        from = NormalizeVersionId(from);
        to = NormalizeVersionId(to);
        _config.Patches.RemoveAll(p =>
            string.Equals(NormalizeVersionId(p.From), from, StringComparison.OrdinalIgnoreCase) &&
            string.Equals(NormalizeVersionId(p.To), to, StringComparison.OrdinalIgnoreCase));
        await SaveConfigAsync();
    }

    public async Task UpdatePatchScriptsAsync(string from, string to, List<string> scripts)
    {
        from = NormalizeVersionId(from);
        to = NormalizeVersionId(to);

        var patch = _config.Patches.FirstOrDefault(p =>
            string.Equals(NormalizeVersionId(p.From), from, StringComparison.OrdinalIgnoreCase) &&
            string.Equals(NormalizeVersionId(p.To), to, StringComparison.OrdinalIgnoreCase));
        if (patch != null)
        {
            patch.Scripts = scripts
                .Select(NormalizeScriptPath)
                .Where(s => !string.IsNullOrWhiteSpace(s))
                .ToList();
        }
        await SaveConfigAsync();
    }

    public async Task MarkPatchManualAsync(string from, string to)
    {
        from = NormalizeVersionId(from);
        to = NormalizeVersionId(to);

        var patch = _config.Patches.FirstOrDefault(p =>
            string.Equals(NormalizeVersionId(p.From), from, StringComparison.OrdinalIgnoreCase) &&
            string.Equals(NormalizeVersionId(p.To), to, StringComparison.OrdinalIgnoreCase));

        if (patch != null && patch.AutoGenerated)
        {
            patch.AutoGenerated = false;
            await SaveConfigAsync();
        }
    }

    public List<string> GetAvailableScripts()
    {
        var scripts = new List<string>();
        if (Directory.Exists(_patchesFolder))
        {
            foreach (var dir in Directory.GetDirectories(_patchesFolder))
            {
                var versionId = Path.GetFileName(dir);
                foreach (var file in Directory.GetFiles(dir, "*.sql"))
                {
                    scripts.Add($"{versionId}/{Path.GetFileName(file)}");
                }
            }
        }
        return scripts;
    }

    public string GetPatchesFolder() => _patchesFolder;

    private static string NormalizeVersionId(string id) => id.Trim();

    private static string NormalizeScriptPath(string path) =>
        path.Trim().Replace('\\', '/');

    private string ToFullScriptPath(string relativePath)
    {
        var normalized = NormalizeScriptPath(relativePath);
        var osPath = normalized.Replace('/', Path.DirectorySeparatorChar);
        var full = Path.GetFullPath(Path.Combine(_patchesFolder, osPath));
        if (!full.StartsWith(_patchesFolderRoot, StringComparison.OrdinalIgnoreCase))
        {
            throw new InvalidOperationException($"Script path escapes patches folder: {relativePath}");
        }

        return full;
    }

    private static string EnsureTrailingSeparator(string path) =>
        path.EndsWith(Path.DirectorySeparatorChar) ? path : path + Path.DirectorySeparatorChar;

    private void AddNonFatalDiagnostic(string phase, string path, Exception ex)
    {
        _nonFatalDiagnostics.Add(
            $"[{DateTime.UtcNow:O}] {phase}: Path='{path}' {ex.GetType().Name}: {ex.Message}");
    }


    private List<VersionInfo> GetReachableVersions(string fromVersionId)
    {
        fromVersionId = NormalizeVersionId(fromVersionId);

        var versionsById = _config.Versions.ToDictionary(v => v.Id, v => v, StringComparer.OrdinalIgnoreCase);
        if (!versionsById.TryGetValue(fromVersionId, out var fromVersion))
            return new List<VersionInfo>();

        var adjacency = _versionGraphService.BuildAdjacencyList(_config.Patches, versionsById);
        var visited = _versionGraphService.GetReachableVersions(fromVersionId, adjacency);

        return visited
            .Where(id => !string.Equals(id, fromVersionId, StringComparison.OrdinalIgnoreCase))
            .Select(id => versionsById[id])
            .Where(v => v.Order > fromVersion.Order)
            .ToList();
    }
}
