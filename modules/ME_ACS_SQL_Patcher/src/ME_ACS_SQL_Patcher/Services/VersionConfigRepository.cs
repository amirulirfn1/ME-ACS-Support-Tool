using System.IO;
using System.Text.Json;
using MagDbPatcher.Models;

namespace MagDbPatcher.Services;

internal sealed class VersionConfigRepository
{
    private static readonly JsonSerializerOptions ReadOptions = new() { PropertyNameCaseInsensitive = true };
    private static readonly JsonSerializerOptions WriteOptions = new()
    {
        WriteIndented = true,
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase
    };

    public async Task<VersionConfig> LoadAsync(string configPath)
    {
        if (!File.Exists(configPath))
            return new VersionConfig();

        var json = await File.ReadAllTextAsync(configPath);
        return JsonSerializer.Deserialize<VersionConfig>(json, ReadOptions) ?? new VersionConfig();
    }

    public async Task SaveAsync(string configPath, VersionConfig config)
    {
        var directory = Path.GetDirectoryName(configPath);
        if (!string.IsNullOrWhiteSpace(directory) && !Directory.Exists(directory))
            Directory.CreateDirectory(directory);

        var json = JsonSerializer.Serialize(config, WriteOptions);
        var tempPath = configPath + ".tmp";
        var backupPath = configPath + ".bak";

        await File.WriteAllTextAsync(tempPath, json);

        if (File.Exists(configPath))
        {
            File.Replace(tempPath, configPath, backupPath, ignoreMetadataErrors: true);
            return;
        }

        File.Move(tempPath, configPath);
    }

    public async Task<PatcherConfig> LoadPatcherConfigAsync(string patcherConfigPath)
    {
        if (!File.Exists(patcherConfigPath))
            return new PatcherConfig();

        var json = await File.ReadAllTextAsync(patcherConfigPath);
        return JsonSerializer.Deserialize<PatcherConfig>(json, ReadOptions) ?? new PatcherConfig();
    }
}
