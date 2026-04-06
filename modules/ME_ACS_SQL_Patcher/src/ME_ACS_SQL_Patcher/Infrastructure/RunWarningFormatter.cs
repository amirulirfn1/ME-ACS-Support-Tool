using System.Globalization;
using MagDbPatcher.Models;

namespace MagDbPatcher.Infrastructure;

public sealed class RunWarningFormatter
{
    public IReadOnlyList<DiagnosticWarningItem> BuildItems(IEnumerable<SqlBatchWarning> warnings)
    {
        var groups = warnings
            .Select((warning, index) => new { warning, index })
            .GroupBy(
                x => new WarningGroupKey(
                    x.warning.ScriptName,
                    x.warning.ErrorNumber,
                    NormalizeMessage(x.warning.ErrorMessage)),
                x => x,
                WarningGroupKeyComparer.Instance)
            .Select(group =>
            {
                var ordered = group.OrderBy(x => x.index).ToList();
                var first = ordered[0].warning;
                return new
                {
                    FirstSeen = ordered[0].index,
                    Item = new DiagnosticWarningItem(
                        Title: $"SQL {first.ErrorNumber} in {first.ScriptName}",
                        Subtitle: BuildBatchSummary(ordered.Select(x => x.warning).ToList()),
                        Details: first.ErrorMessage.Trim())
                };
            })
            .OrderBy(x => x.FirstSeen)
            .Select(x => x.Item)
            .ToList();

        return groups;
    }

    public IReadOnlyList<string> BuildDiagnosticsLines(IEnumerable<SqlBatchWarning> warnings)
    {
        var warningList = warnings.ToList();
        if (warningList.Count == 0)
            return Array.Empty<string>();

        var groupedItems = BuildItems(warningList);
        var errorSummary = warningList
            .GroupBy(warning => warning.ErrorNumber)
            .OrderByDescending(group => group.Count())
            .ThenBy(group => group.Key)
            .Take(5)
            .Select(group => $"SQL {group.Key} x{group.Count()}")
            .ToList();

        var lines = new List<string>
        {
            $"Total SQL warnings: {warningList.Count}",
            $"Unique warning groups: {groupedItems.Count}"
        };

        if (errorSummary.Count > 0)
            lines.Add($"Top SQL errors: {string.Join(", ", errorSummary)}");

        lines.Add(string.Empty);
        lines.Add("Warning Groups:");

        for (var i = 0; i < groupedItems.Count; i++)
        {
            var item = groupedItems[i];
            lines.Add($"{i + 1}. {item.Title}");
            lines.Add($"   {item.Subtitle}");
            lines.Add($"   {item.Details}");
        }

        return lines;
    }

    private static string BuildBatchSummary(IReadOnlyList<SqlBatchWarning> warnings)
    {
        var orderedBatches = warnings
            .Select(warning => warning.BatchIndex)
            .Distinct()
            .OrderBy(index => index)
            .ToList();

        if (orderedBatches.Count == 0)
            return "Batch details unavailable";

        var batchCount = warnings[0].BatchCount;
        if (orderedBatches.Count == 1)
            return $"Batch {orderedBatches[0].ToString(CultureInfo.InvariantCulture)}/{batchCount.ToString(CultureInfo.InvariantCulture)}";

        var preview = string.Join(
            ", ",
            orderedBatches
                .Take(6)
                .Select(index => index.ToString(CultureInfo.InvariantCulture)));

        var remaining = orderedBatches.Count - Math.Min(orderedBatches.Count, 6);
        if (remaining > 0)
            preview = $"{preview}, +{remaining} more";

        return $"{orderedBatches.Count.ToString(CultureInfo.InvariantCulture)} batches affected: {preview} of {batchCount.ToString(CultureInfo.InvariantCulture)}";
    }

    private static string NormalizeMessage(string message)
        => string.Join(" ", (message ?? string.Empty).Split((char[]?)null, StringSplitOptions.RemoveEmptyEntries));

    private sealed record WarningGroupKey(string ScriptName, int ErrorNumber, string ErrorMessage);

    private sealed class WarningGroupKeyComparer : IEqualityComparer<WarningGroupKey>
    {
        public static WarningGroupKeyComparer Instance { get; } = new();

        public bool Equals(WarningGroupKey? x, WarningGroupKey? y)
        {
            if (ReferenceEquals(x, y))
                return true;

            if (x is null || y is null)
                return false;

            return string.Equals(x.ScriptName, y.ScriptName, StringComparison.OrdinalIgnoreCase)
                && x.ErrorNumber == y.ErrorNumber
                && string.Equals(x.ErrorMessage, y.ErrorMessage, StringComparison.OrdinalIgnoreCase);
        }

        public int GetHashCode(WarningGroupKey obj)
        {
            return HashCode.Combine(
                StringComparer.OrdinalIgnoreCase.GetHashCode(obj.ScriptName),
                obj.ErrorNumber,
                StringComparer.OrdinalIgnoreCase.GetHashCode(obj.ErrorMessage));
        }
    }
}
