namespace MagDbPatcher.Models;

public class PatchPackManifest
{
    public int SchemaVersion { get; set; } = 1;
    public string PackVersion { get; set; } = "";
    public DateTimeOffset ReleasedAt { get; set; } = DateTimeOffset.UtcNow;
    public string MinAppVersion { get; set; } = "1.0.0";
    public string? Notes { get; set; }
    public string ContentRoot { get; set; } = "patches";
}

