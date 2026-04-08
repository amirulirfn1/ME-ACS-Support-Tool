using System.Text.Json.Serialization;

namespace MagDbPatcher.Models;

public class AppSettings
{
    public string? PatchTempFolder { get; set; }
    public int WarningThreshold { get; set; } = 10;

    [JsonConverter(typeof(JsonStringEnumConverter))]
    public PatchErrorMode PatchErrorMode { get; set; } = PatchErrorMode.WarnAndContinue;

    public string? PatchesFolder { get; set; }
    public string? LastSqlServer { get; set; }
    public string? LastOutputFolder { get; set; }
    public List<string> RecentBackupFiles { get; set; } = new();
    public string? LastImportedPatchPack { get; set; }

    [JsonConverter(typeof(JsonStringEnumConverter))]
    public SqlAuthMode SqlAuthMode { get; set; } = SqlAuthMode.Windows;

    public string? SqlUsername { get; set; }
    public bool IsDarkTheme { get; set; } = false;
}
