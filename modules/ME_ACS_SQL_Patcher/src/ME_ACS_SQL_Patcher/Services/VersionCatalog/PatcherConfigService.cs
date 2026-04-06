using System.IO;
using MagDbPatcher.Models;

namespace MagDbPatcher.Services;

internal sealed class PatcherConfigService
{
    public async Task<PatcherConfig> LoadAsync(string patcherConfigPath, VersionConfigRepository repository)
    {
        if (!File.Exists(patcherConfigPath))
        {
            return new PatcherConfig
            {
                SchemaVersion = 1,
                VersionOrdering = new VersionOrderingConfig { Mode = "semantic_with_optional_buildDate" },
                AutoGenerate = new AutoGenerateConfig
                {
                    BuildVersionPattern = "-",
                    Rules = new List<AutoGenerateRule>
                    {
                        new() { Type = "stable_to_build_same_major" },
                        new()
                        {
                            Type = "from_versions_to_build_major",
                            FromVersions = new List<string> { "6.5" },
                            ToMajor = 7
                        }
                    }
                }
            };
        }

        try
        {
            var config = await repository.LoadPatcherConfigAsync(patcherConfigPath);
            config.VersionOrdering ??= new VersionOrderingConfig();
            config.AutoGenerate ??= new AutoGenerateConfig();
            config.AutoGenerate.Rules ??= new List<AutoGenerateRule>();
            if (string.IsNullOrWhiteSpace(config.AutoGenerate.BuildVersionPattern))
                config.AutoGenerate.BuildVersionPattern = "-";
            if (string.IsNullOrWhiteSpace(config.VersionOrdering.Mode))
                config.VersionOrdering.Mode = "semantic_with_optional_buildDate";
            return config;
        }
        catch
        {
            return new PatcherConfig();
        }
    }
}
