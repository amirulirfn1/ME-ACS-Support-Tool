using System.IO;
using System.Text.Json;
using System.Text.Json.Serialization;
using MEACSSupportTool.Models;

namespace MEACSSupportTool.Services;

public sealed class SupportToolSettingsService
{
    private readonly string _settingsPath;

    public SupportToolSettingsService(string rootDirectory)
    {
        _settingsPath = Path.Combine(rootDirectory, "settings.json");
    }

    public async Task<SupportToolSettings> LoadAsync()
    {
        if (!File.Exists(_settingsPath))
        {
            return new SupportToolSettings();
        }

        try
        {
            var json = await File.ReadAllTextAsync(_settingsPath);
            return JsonSerializer.Deserialize<SupportToolSettings>(json, new JsonSerializerOptions
            {
                PropertyNameCaseInsensitive = true
            }) ?? new SupportToolSettings();
        }
        catch
        {
            return new SupportToolSettings();
        }
    }

    public async Task SaveAsync(SupportToolSettings settings)
    {
        var directory = Path.GetDirectoryName(_settingsPath);
        if (!string.IsNullOrWhiteSpace(directory))
        {
            Directory.CreateDirectory(directory);
        }

        var json = JsonSerializer.Serialize(settings, new JsonSerializerOptions
        {
            WriteIndented = true,
            DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull
        });

        await File.WriteAllTextAsync(_settingsPath, json);
    }
}
