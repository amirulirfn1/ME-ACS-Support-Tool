using MagDbPatcher.Models;

namespace MagDbPatcher.Services;

public interface IAppSettingsService
{
    Task<AppSettings> LoadAsync();
    Task SaveAsync(AppSettings settings);
}
