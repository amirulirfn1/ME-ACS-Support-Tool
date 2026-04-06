using MagDbPatcher.Models;

namespace MagDbPatcher.Services;

internal sealed class VersionGraphService
{
    public Dictionary<string, List<PatchEdge>> BuildAdjacencyList(
        IEnumerable<PatchInfo> patches,
        Dictionary<string, VersionInfo> versionsById)
    {
        var adjacency = new Dictionary<string, List<PatchEdge>>(StringComparer.OrdinalIgnoreCase);

        foreach (var patch in patches)
        {
            var from = patch.From.Trim();
            var to = patch.To.Trim();

            if (!versionsById.TryGetValue(from, out var fromV))
                continue;
            if (!versionsById.TryGetValue(to, out var toV))
                continue;

            if (toV.Order <= fromV.Order)
                continue;

            if (!adjacency.TryGetValue(from, out var list))
            {
                list = new List<PatchEdge>();
                adjacency[from] = list;
            }

            list.Add(new PatchEdge(to, toV.Order));
        }

        foreach (var list in adjacency.Values)
        {
            list.Sort((a, b) =>
            {
                var cmp = a.ToOrder.CompareTo(b.ToOrder);
                if (cmp != 0) return cmp;
                return StringComparer.OrdinalIgnoreCase.Compare(a.To, b.To);
            });
        }

        return adjacency;
    }

    public List<string> GetReachableVersions(
        string fromVersionId,
        Dictionary<string, List<PatchEdge>> adjacency)
    {
        var queue = new Queue<string>();
        var visited = new HashSet<string>(StringComparer.OrdinalIgnoreCase);

        queue.Enqueue(fromVersionId);
        visited.Add(fromVersionId);

        while (queue.Count > 0)
        {
            var current = queue.Dequeue();
            if (!adjacency.TryGetValue(current, out var edges))
                continue;

            foreach (var edge in edges)
            {
                if (!visited.Add(edge.To))
                    continue;

                queue.Enqueue(edge.To);
            }
        }

        return visited.ToList();
    }

    public List<string> FindShortestPathBySteps(
        string fromVersionId,
        string toVersionId,
        Dictionary<string, List<PatchEdge>> adjacency)
    {
        var queue = new Queue<string>();
        var prev = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        var visited = new HashSet<string>(StringComparer.OrdinalIgnoreCase);

        queue.Enqueue(fromVersionId);
        visited.Add(fromVersionId);

        while (queue.Count > 0)
        {
            var current = queue.Dequeue();
            if (string.Equals(current, toVersionId, StringComparison.OrdinalIgnoreCase))
                break;

            if (!adjacency.TryGetValue(current, out var edges))
                continue;

            foreach (var edge in edges)
            {
                if (!visited.Add(edge.To))
                    continue;

                prev[edge.To] = current;
                queue.Enqueue(edge.To);
            }
        }

        if (!visited.Contains(toVersionId))
            return new List<string>();

        var pathVersions = new List<string> { toVersionId };
        var cursor = toVersionId;
        while (!string.Equals(cursor, fromVersionId, StringComparison.OrdinalIgnoreCase))
        {
            cursor = prev[cursor];
            pathVersions.Add(cursor);
        }
        pathVersions.Reverse();
        return pathVersions;
    }
}

internal readonly record struct PatchEdge(string To, int ToOrder);
