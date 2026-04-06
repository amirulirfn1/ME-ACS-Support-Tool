using System.IO;
using MagDbPatcher.Models;

namespace MagDbPatcher.Services;

internal sealed class VersionCatalogValidationService
{
    public ConfigValidationResult Validate(
        VersionConfig config,
        Func<string, string> normalizeVersionId,
        Func<string, string> normalizeScriptPath,
        Func<string, string> toFullScriptPath)
    {
        var result = new ConfigValidationResult();
        var versionsById = new Dictionary<string, VersionInfo>(StringComparer.OrdinalIgnoreCase);

        foreach (var version in config.Versions)
        {
            if (string.IsNullOrWhiteSpace(version.Id))
            {
                result.Errors.Add(new ConfigIssue(ConfigIssueSeverity.Error, "Version id is empty."));
                continue;
            }

            if (versionsById.ContainsKey(version.Id))
            {
                result.Errors.Add(new ConfigIssue(ConfigIssueSeverity.Error, $"Duplicate version id '{version.Id}'."));
                continue;
            }

            versionsById[version.Id] = version;
        }

        foreach (var group in config.Versions.GroupBy(version => version.Order))
        {
            if (group.Key <= 0)
            {
                foreach (var version in group)
                {
                    result.Warnings.Add(new ConfigIssue(
                        ConfigIssueSeverity.Warning,
                        $"Version '{version.Id}' has non-positive order '{version.Order}'."));
                }
            }
            else if (group.Count() > 1)
            {
                result.Warnings.Add(new ConfigIssue(
                    ConfigIssueSeverity.Warning,
                    $"Duplicate order '{group.Key}' for versions: {string.Join(", ", group.Select(version => version.Id))}"));
            }
        }

        foreach (var patch in config.Patches)
        {
            if (string.IsNullOrWhiteSpace(patch.From) || string.IsNullOrWhiteSpace(patch.To))
            {
                result.Errors.Add(new ConfigIssue(ConfigIssueSeverity.Error, "Patch has empty from/to version."));
                continue;
            }

            var from = normalizeVersionId(patch.From);
            var to = normalizeVersionId(patch.To);
            if (!versionsById.ContainsKey(from))
                result.Errors.Add(new ConfigIssue(ConfigIssueSeverity.Error, $"Patch references missing from version '{patch.From}'."));
            if (!versionsById.ContainsKey(to))
                result.Errors.Add(new ConfigIssue(ConfigIssueSeverity.Error, $"Patch references missing to version '{patch.To}'."));

            if (patch.Scripts.Count == 0)
            {
                result.Warnings.Add(new ConfigIssue(ConfigIssueSeverity.Warning, $"Patch {patch.From} -> {patch.To} has no scripts configured."));
            }

            foreach (var script in patch.Scripts.Select(normalizeScriptPath))
            {
                if (string.IsNullOrWhiteSpace(script))
                    continue;

                string fullPath;
                try
                {
                    fullPath = toFullScriptPath(script);
                }
                catch (InvalidOperationException ex)
                {
                    result.Errors.Add(new ConfigIssue(ConfigIssueSeverity.Error, ex.Message));
                    continue;
                }

                if (!File.Exists(fullPath))
                    result.Errors.Add(new ConfigIssue(ConfigIssueSeverity.Error, $"Missing script file: {script}"));
            }
        }

        foreach (var version in config.Versions)
        {
            if (string.IsNullOrWhiteSpace(version.UpgradesTo))
                continue;

            var seen = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
            var current = version.Id;
            while (true)
            {
                if (!seen.Add(current))
                {
                    result.Warnings.Add(new ConfigIssue(
                        ConfigIssueSeverity.Warning,
                        $"Cycle detected in upgradesTo chain starting at '{version.Id}'."));
                    break;
                }

                if (!versionsById.TryGetValue(current, out var currentVersion))
                    break;

                if (string.IsNullOrWhiteSpace(currentVersion.UpgradesTo))
                    break;

                current = currentVersion.UpgradesTo!;
            }
        }

        if (HasPatchCycle(config, versionsById))
            result.Warnings.Add(new ConfigIssue(ConfigIssueSeverity.Warning, "Cycle detected in patch graph."));

        return result;
    }

    private static bool HasPatchCycle(VersionConfig config, Dictionary<string, VersionInfo> versionsById)
    {
        var adjacency = config.Patches
            .Where(patch => versionsById.ContainsKey(patch.From) && versionsById.ContainsKey(patch.To))
            .GroupBy(patch => patch.From, StringComparer.OrdinalIgnoreCase)
            .ToDictionary(
                group => group.Key,
                group => group.Select(patch => patch.To).Distinct(StringComparer.OrdinalIgnoreCase).ToList(),
                StringComparer.OrdinalIgnoreCase);

        var color = new Dictionary<string, int>(StringComparer.OrdinalIgnoreCase);

        bool Dfs(string node)
        {
            if (color.TryGetValue(node, out var state))
            {
                if (state == 1) return true;
                if (state == 2) return false;
            }

            color[node] = 1;
            if (adjacency.TryGetValue(node, out var next))
            {
                foreach (var child in next)
                {
                    if (Dfs(child))
                        return true;
                }
            }

            color[node] = 2;
            return false;
        }

        foreach (var id in versionsById.Keys)
        {
            if (Dfs(id))
                return true;
        }

        return false;
    }
}

