namespace MagDbPatcher.Models;

public sealed class PatchCatalogSnapshot
{
    public string RootPath { get; init; } = string.Empty;
    public IReadOnlyList<VersionInfo> Versions { get; init; } = Array.Empty<VersionInfo>();
    public IReadOnlyList<PatchInfo> Patches { get; init; } = Array.Empty<PatchInfo>();
    public IReadOnlyList<string> AvailableScripts { get; init; } = Array.Empty<string>();
    public ConfigValidationResult Validation { get; init; } = new();
    public IReadOnlyList<string> Diagnostics { get; init; } = Array.Empty<string>();
}

public sealed class PatchCatalogMutation
{
    public List<VersionMutation> Versions { get; init; } = new();
    public List<PatchLinkMutation> PatchLinks { get; init; } = new();
}

public enum VersionMutationType
{
    AddOrUpdate,
    Delete
}

public sealed class VersionMutation
{
    public VersionMutationType Type { get; init; } = VersionMutationType.AddOrUpdate;
    public string VersionId { get; init; } = string.Empty;
    public string Name { get; init; } = string.Empty;
    public string? UpgradesTo { get; init; }
    public int? Order { get; init; }
}

public enum PatchLinkMutationType
{
    AddOrUpdate,
    Delete
}

public sealed class PatchLinkMutation
{
    public PatchLinkMutationType Type { get; init; } = PatchLinkMutationType.AddOrUpdate;
    public string FromVersion { get; init; } = string.Empty;
    public string ToVersion { get; init; } = string.Empty;
    public List<string> Scripts { get; init; } = new();
    public bool Manual { get; init; } = false;
}

public sealed class PatchFolderChangeRequest
{
    public string CurrentFolder { get; init; } = string.Empty;
    public string RequestedFolder { get; init; } = string.Empty;
}
