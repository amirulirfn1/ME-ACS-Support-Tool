using System.IO;
using System.Text.Json;
using System.Text.Json.Serialization;
using MagDbPatcher.Infrastructure;
using MagDbPatcher.Models;

namespace MagDbPatcher.Services;

public class AppSettingsService : IAppSettingsService
{
    private readonly string _settingsPath;
    private readonly Action<string, Exception?> _logWarning;

    public AppSettingsService(string? settingsPath, Action<string, Exception?>? logWarning = null)
        : this(appPaths: null, settingsPath, logWarning)
    {
    }

    public AppSettingsService(AppRuntimePaths? appPaths = null, string? settingsPath = null, Action<string, Exception?>? logWarning = null)
    {
        if (string.IsNullOrWhiteSpace(settingsPath))
        {
            _settingsPath = (appPaths ?? AppRuntimePaths.CreateDefault()).SettingsFilePath;
        }
        else
        {
            _settingsPath = settingsPath;
        }

        _logWarning = logWarning ?? ((message, ex) => DiagnosticsLog.Warning("AppSettingsService", message, ex));
    }

    public async Task<AppSettings> LoadAsync()
    {
        if (!File.Exists(_settingsPath))
            return new AppSettings();

        try
        {
            var json = await File.ReadAllTextAsync(_settingsPath);
            var options = new JsonSerializerOptions { PropertyNameCaseInsensitive = true };
            return JsonSerializer.Deserialize<AppSettings>(json, options) ?? new AppSettings();
        }
        catch (JsonException ex)
        {
            _logWarning($"Failed to parse settings at '{_settingsPath}'. Falling back to defaults.", ex);
            return new AppSettings();
        }
        catch (IOException ex)
        {
            _logWarning($"Failed to read settings at '{_settingsPath}'. Falling back to defaults.", ex);
            return new AppSettings();
        }
        catch
        {
            _logWarning($"Unexpected error while loading settings at '{_settingsPath}'. Falling back to defaults.", null);
            return new AppSettings();
        }
    }

    public async Task SaveAsync(AppSettings settings)
    {
        var dir = Path.GetDirectoryName(_settingsPath);
        if (!string.IsNullOrWhiteSpace(dir) && !Directory.Exists(dir))
        {
            Directory.CreateDirectory(dir);
        }

        var options = new JsonSerializerOptions
        {
            WriteIndented = true,
            DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull
        };
        options.Converters.Add(new JsonStringEnumConverter());

        var json = JsonSerializer.Serialize(settings, options);
        await File.WriteAllTextAsync(_settingsPath, json);
    }
}
