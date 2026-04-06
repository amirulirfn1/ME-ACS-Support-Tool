using System.Text.Json;
using MagDbPatcher.Infrastructure;
using MagDbPatcher.Models;
using MagDbPatcher.Services;
using Xunit;

namespace MagDbPatcher.Tests;

public class AppSettingsTests
{
    [Fact]
    public void AppSettings_IgnoresLegacyUnknownProperties()
    {
        var json = """
                   {
                     "showAdminTools": true,
                     "lastSqlServer": ".\\MAGSQL"
                   }
                   """;

        var options = new JsonSerializerOptions { PropertyNameCaseInsensitive = true };
        var settings = JsonSerializer.Deserialize<AppSettings>(json, options);

        Assert.NotNull(settings);
        Assert.Equal(".\\MAGSQL", settings.LastSqlServer);
    }

    [Fact]
    public async Task LoadAsync_MalformedJson_ReturnsDefaults_AndLogsWarning()
    {
        var root = Path.Combine(Path.GetTempPath(), "MagDbPatcher.Tests", Guid.NewGuid().ToString("N"));
        Directory.CreateDirectory(root);
        var settingsPath = Path.Combine(root, "settings.json");
        await File.WriteAllTextAsync(settingsPath, "{ not-valid-json");

        var logs = new List<string>();
        var service = new AppSettingsService(settingsPath, (message, ex) => logs.Add($"{message}|{ex?.GetType().Name}"));

        var loaded = await service.LoadAsync();

        Assert.NotNull(loaded);
        Assert.Empty(loaded.RecentBackupFiles);
        Assert.Single(logs);
        Assert.Contains("Falling back to defaults", logs[0], StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    public async Task SaveAsync_UsesManagedSettingsPath_WhenAppPathsProvided()
    {
        var root = Path.Combine(Path.GetTempPath(), "MagDbPatcher.Tests", Guid.NewGuid().ToString("N"));
        Directory.CreateDirectory(root);

        var appPaths = TestAppPaths.Create(root);
        var service = new AppSettingsService(appPaths);
        await service.SaveAsync(new AppSettings { LastSqlServer = @".\MAGSQL" });

        Assert.True(File.Exists(appPaths.SettingsFilePath));
        var loaded = await service.LoadAsync();
        Assert.Equal(@".\MAGSQL", loaded.LastSqlServer);
    }
}
