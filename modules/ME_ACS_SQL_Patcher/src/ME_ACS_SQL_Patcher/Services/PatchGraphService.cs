using MagDbPatcher.Models;

namespace MagDbPatcher.Services;

internal sealed class PatchGraphService
{
    private readonly VersionGraphService _inner = new();

    public Dictionary<string, List<PatchEdge>> BuildAdjacency(
        IReadOnlyList<PatchInfo> patches,
        IReadOnlyList<VersionInfo> versions)
    {
        var versionsById = versions.ToDictionary(v => v.Id, v => v, StringComparer.OrdinalIgnoreCase);
        return _inner.BuildAdjacencyList(patches, versionsById);
    }

    public List<string> FindShortestPath(
        string fromVersion,
        string toVersion,
        IReadOnlyList<PatchInfo> patches,
        IReadOnlyList<VersionInfo> versions)
    {
        var adjacency = BuildAdjacency(patches, versions);
        return _inner.FindShortestPathBySteps(fromVersion, toVersion, adjacency);
    }
}
