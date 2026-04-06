using System.Text;
using MagDbPatcher.Models;

namespace MagDbPatcher.Infrastructure;

public sealed class AdminVersionChainFormatter
{
    public string Format(IReadOnlyList<VersionInfo> versions)
    {
        if (versions.Count == 0)
            return "(no versions)";

        var parts = new StringBuilder();
        foreach (var version in versions)
        {
            if (parts.Length > 0)
                parts.Append("  ->  ");
            parts.Append(version.Id);
        }

        return parts.ToString();
    }
}
