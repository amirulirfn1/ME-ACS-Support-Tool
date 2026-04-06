using System.Globalization;
using System.Reflection;

namespace MEACSSupportTool.Infrastructure;

public static class SupportToolMetadata
{
    private static readonly Assembly EntryAssembly = Assembly.GetEntryAssembly() ?? Assembly.GetExecutingAssembly();

    public static string Title =>
        EntryAssembly.GetCustomAttribute<AssemblyTitleAttribute>()?.Title
        ?? EntryAssembly.GetName().Name
        ?? "ME ACS Support Tool";

    public static string Subtitle => "Unified support toolkit for MAG support staff";

    public static string DisplayVersion
    {
        get
        {
            var informational = EntryAssembly.GetCustomAttribute<AssemblyInformationalVersionAttribute>()?.InformationalVersion;
            if (!string.IsNullOrWhiteSpace(informational))
            {
                return informational.Split('+', 2)[0];
            }

            var fileVersion = EntryAssembly.GetCustomAttribute<AssemblyFileVersionAttribute>()?.Version;
            if (!string.IsNullOrWhiteSpace(fileVersion))
            {
                return fileVersion;
            }

            return EntryAssembly.GetName().Version?.ToString(3) ?? "1.0.0";
        }
    }

    public static DateTime BuildDate
    {
        get
        {
            var raw = EntryAssembly
                .GetCustomAttributes<AssemblyMetadataAttribute>()
                .FirstOrDefault(attribute => attribute.Key == "BuildDate")?.Value;

            return DateTime.TryParse(raw, null, DateTimeStyles.RoundtripKind, out var parsed)
                ? parsed
                : DateTime.MinValue;
        }
    }

    public static string BuildLabel
    {
        get
        {
            if (BuildDate == DateTime.MinValue)
            {
                return $"Version {DisplayVersion}";
            }

            return $"Version {DisplayVersion} | {BuildDate.AddHours(8):dd MMM yyyy HH:mm} MYT";
        }
    }
}
