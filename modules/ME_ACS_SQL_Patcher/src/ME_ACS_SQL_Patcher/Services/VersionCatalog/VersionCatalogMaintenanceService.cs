using System.IO;
using MagDbPatcher.Models;

namespace MagDbPatcher.Services;

internal sealed class VersionCatalogMaintenanceService
{
    private readonly PatchAutoGenerationService _patchAutoGenerationService;

    public VersionCatalogMaintenanceService(PatchAutoGenerationService patchAutoGenerationService)
    {
        _patchAutoGenerationService = patchAutoGenerationService;
    }

    public bool RunLoadPipeline(VersionConfig config, PatcherConfig patcherConfig, string patchesFolder)
    {
        var changed = NormalizeConfig(config);
        changed |= ApplyVersionOrdering(config, patcherConfig);
        changed |= SyncWithFolders(config, patchesFolder);
        changed |= NormalizeConfig(config);
        changed |= ApplyVersionOrdering(config, patcherConfig);
        changed |= AutoGeneratePatches(config, patcherConfig, patchesFolder);
        return changed;
    }

    private bool SyncWithFolders(VersionConfig config, string patchesFolder)
    {
        if (!Directory.Exists(patchesFolder))
            return false;

        var folders = Directory.GetDirectories(patchesFolder)
            .Select(Path.GetFileName)
            .Where(name => !string.IsNullOrWhiteSpace(name))
            .ToList();

        var changed = false;
        var maxOrder = config.Versions.Any() ? config.Versions.Max(v => v.Order) : 0;
        var newVersions = new List<VersionInfo>();

        foreach (var folderName in folders)
        {
            var existingVersion = config.Versions.FirstOrDefault(v =>
                string.Equals(v.Id, folderName, StringComparison.OrdinalIgnoreCase));

            if (existingVersion == null)
            {
                maxOrder++;
                var newVersion = new VersionInfo
                {
                    Id = folderName!,
                    Name = folderName!,
                    UpgradesTo = null,
                    Order = maxOrder
                };
                config.Versions.Add(newVersion);
                newVersions.Add(newVersion);
                changed = true;
            }
        }

        if (newVersions.Count > 0)
        {
            foreach (var newVersion in newVersions.OrderBy(v => v.Order))
            {
                var major = PatchAutoGenerationService.GetMajorVersion(newVersion.Id);
                if (major == null)
                    continue;

                var tail = config.Versions
                    .Where(v => !string.Equals(v.Id, newVersion.Id, StringComparison.OrdinalIgnoreCase))
                    .Where(v => PatchAutoGenerationService.GetMajorVersion(v.Id) == major)
                    .OrderByDescending(v => v.Order)
                    .FirstOrDefault(v => string.IsNullOrWhiteSpace(v.UpgradesTo));

                if (tail != null)
                {
                    tail.UpgradesTo = newVersion.Id;
                    changed = true;
                }
            }
        }

        return changed;
    }

    private bool AutoGeneratePatches(VersionConfig config, PatcherConfig patcherConfig, string patchesFolder)
    {
        var changed = false;
        var desired = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        var scriptsByVersion = config.Versions.ToDictionary(
            version => version.Id,
            version => _patchAutoGenerationService.GetScriptsInFolder(patchesFolder, version.Id),
            StringComparer.OrdinalIgnoreCase);

        foreach (var version in config.Versions)
        {
            if (string.IsNullOrWhiteSpace(version.UpgradesTo))
                continue;

            if (_patchAutoGenerationService.EnsureAutoPatch(config.Patches, version.Id, version.UpgradesTo!, scriptsByVersion, desired))
                changed = true;
        }

        var rules = patcherConfig.AutoGenerate.Rules ?? new List<AutoGenerateRule>();
        var buildPattern = string.IsNullOrWhiteSpace(patcherConfig.AutoGenerate.BuildVersionPattern)
            ? "-"
            : patcherConfig.AutoGenerate.BuildVersionPattern;

        var stableVersions = config.Versions
            .Where(v => !PatchAutoGenerationService.IsBuildVersion(v.Id, buildPattern))
            .OrderBy(v => v.Order)
            .ToList();
        var buildVersions = config.Versions
            .Where(v => PatchAutoGenerationService.IsBuildVersion(v.Id, buildPattern))
            .OrderBy(v => v.Order)
            .ToList();

        var stableToBuildEnabled = rules.Any(rule =>
            string.Equals((rule.Type ?? string.Empty).Trim(), "stable_to_build_same_major", StringComparison.OrdinalIgnoreCase));

        var fromToBuildRules = rules
            .Where(rule => string.Equals((rule.Type ?? string.Empty).Trim(), "from_versions_to_build_major", StringComparison.OrdinalIgnoreCase))
            .Where(rule => rule.ToMajor != null && rule.FromVersions != null && rule.FromVersions.Count > 0)
            .ToList();

        foreach (var target in buildVersions)
        {
            var targetMajor = PatchAutoGenerationService.GetMajorVersion(target.Id);

            if (stableToBuildEnabled && targetMajor != null)
            {
                foreach (var source in stableVersions.Where(source =>
                             PatchAutoGenerationService.GetMajorVersion(source.Id) == targetMajor && source.Order < target.Order))
                {
                    if (_patchAutoGenerationService.EnsureAutoPatch(config.Patches, source.Id, target.Id, scriptsByVersion, desired))
                        changed = true;
                }
            }

            if (targetMajor != null)
            {
                foreach (var rule in fromToBuildRules.Where(rule => rule.ToMajor == targetMajor))
                {
                    foreach (var from in rule.FromVersions!.Select(NormalizeVersionId))
                    {
                        var sourceVersion = config.Versions.FirstOrDefault(version =>
                            string.Equals(NormalizeVersionId(version.Id), from, StringComparison.OrdinalIgnoreCase));
                        if (sourceVersion == null || target.Order <= sourceVersion.Order)
                            continue;

                        if (_patchAutoGenerationService.EnsureAutoPatch(config.Patches, from, target.Id, scriptsByVersion, desired))
                            changed = true;
                    }
                }
            }
        }

        var orderedVersions = config.Versions
            .OrderBy(v => v.Order)
            .ToList();

        foreach (var source in orderedVersions.Where(version => IsVersionAtLeastSixFive(version.Id)))
        {
            foreach (var target in orderedVersions.Where(version => version.Order > source.Order))
            {
                if (_patchAutoGenerationService.EnsureAutoPatch(config.Patches, source.Id, target.Id, scriptsByVersion, desired))
                    changed = true;
            }
        }

        var removed = config.Patches.RemoveAll(patch => patch.AutoGenerated && !desired.Contains(PatchAutoGenerationService.Key(patch.From, patch.To)));
        if (removed > 0)
            changed = true;

        return changed;
    }

    private static bool ApplyVersionOrdering(VersionConfig config, PatcherConfig patcherConfig)
    {
        var mode = (patcherConfig.VersionOrdering.Mode ?? string.Empty).Trim();
        if (!mode.Equals("semantic_with_optional_buildDate", StringComparison.OrdinalIgnoreCase))
            return false;

        var ordered = config.Versions
            .Select(version => (Version: version, Key: ParseVersionKey(version.Id)))
            .OrderBy(item => item.Key)
            .ThenBy(item => item.Version.Id, StringComparer.OrdinalIgnoreCase)
            .ToList();

        var changed = false;
        for (var index = 0; index < ordered.Count; index++)
        {
            var desiredOrder = index + 1;
            if (ordered[index].Version.Order != desiredOrder)
            {
                ordered[index].Version.Order = desiredOrder;
                changed = true;
            }
        }

        return changed;
    }

    private static bool NormalizeConfig(VersionConfig config)
    {
        var changed = false;

        foreach (var version in config.Versions)
        {
            var id = NormalizeVersionId(version.Id);
            if (!string.Equals(id, version.Id, StringComparison.Ordinal))
            {
                version.Id = id;
                changed = true;
            }

            var name = version.Name.Trim();
            if (!string.Equals(name, version.Name, StringComparison.Ordinal))
            {
                version.Name = name;
                changed = true;
            }

            var upgradesTo = version.UpgradesTo == null ? null : NormalizeVersionId(version.UpgradesTo);
            if (!string.Equals(upgradesTo, version.UpgradesTo, StringComparison.Ordinal))
            {
                version.UpgradesTo = upgradesTo;
                changed = true;
            }
        }

        foreach (var patch in config.Patches)
        {
            var from = NormalizeVersionId(patch.From);
            if (!string.Equals(from, patch.From, StringComparison.Ordinal))
            {
                patch.From = from;
                changed = true;
            }

            var to = NormalizeVersionId(patch.To);
            if (!string.Equals(to, patch.To, StringComparison.Ordinal))
            {
                patch.To = to;
                changed = true;
            }

            var normalizedScripts = patch.Scripts
                .Select(NormalizeScriptPath)
                .Where(script => !string.IsNullOrWhiteSpace(script))
                .ToList();

            if (!patch.Scripts.SequenceEqual(normalizedScripts))
            {
                patch.Scripts = normalizedScripts;
                changed = true;
            }
        }

        return changed;
    }

    private static string NormalizeVersionId(string id) => id.Trim();

    private static string NormalizeScriptPath(string path) => path.Trim().Replace('\\', '/');

    private static bool IsVersionAtLeastSixFive(string id)
    {
        var key = ParseVersionKey(id);
        if (key.Major > 6)
            return true;
        if (key.Major < 6)
            return false;
        return key.Minor >= 5;
    }

    private static VersionOrderingKey ParseVersionKey(string id)
    {
        var raw = (id ?? string.Empty).Trim();
        if (raw.Length == 0)
            return new VersionOrderingKey(0, 0, 0, 0, string.Empty);

        var parts = raw.Split('-', 2, StringSplitOptions.RemoveEmptyEntries);
        var basePart = parts[0];
        var buildSuffix = parts.Length > 1 ? parts[1].Trim() : string.Empty;

        var numbers = basePart.Split('.', StringSplitOptions.RemoveEmptyEntries);
        var major = numbers.Length > 0 && int.TryParse(numbers[0], out var parsedMajor) ? parsedMajor : 0;
        var minor = numbers.Length > 1 && int.TryParse(numbers[1], out var parsedMinor) ? parsedMinor : 0;
        var patch = numbers.Length > 2 && int.TryParse(numbers[2], out var parsedPatch) ? parsedPatch : 0;

        var buildDate = 0;
        if (!string.IsNullOrWhiteSpace(buildSuffix))
            buildDate = int.TryParse(buildSuffix, out var parsedDate) ? parsedDate : 99999999;

        return new VersionOrderingKey(major, minor, patch, buildDate, buildSuffix);
    }
}

internal readonly record struct VersionOrderingKey(int Major, int Minor, int Patch, int BuildDate, string BuildSuffix)
    : IComparable<VersionOrderingKey>
{
    public int CompareTo(VersionOrderingKey other)
    {
        var comparison = Major.CompareTo(other.Major);
        if (comparison != 0) return comparison;
        comparison = Minor.CompareTo(other.Minor);
        if (comparison != 0) return comparison;
        comparison = Patch.CompareTo(other.Patch);
        if (comparison != 0) return comparison;
        comparison = BuildDate.CompareTo(other.BuildDate);
        if (comparison != 0) return comparison;
        return StringComparer.OrdinalIgnoreCase.Compare(BuildSuffix, other.BuildSuffix);
    }
}
