using System.Globalization;
using System.IO;
using System.Reflection;
using System.Text.Json;

namespace MagDbPatcher.Infrastructure;

public static class AppMetadata
{
    private static readonly Assembly EntryAssembly = Assembly.GetEntryAssembly() ?? Assembly.GetExecutingAssembly();

    public static string Title =>
        EntryAssembly.GetCustomAttribute<AssemblyTitleAttribute>()?.Title
        ?? EntryAssembly.GetName().Name
        ?? "ME_ACS SQL Patcher";

    public static string DisplayVersion
    {
        get
        {
            var informational = EntryAssembly.GetCustomAttribute<AssemblyInformationalVersionAttribute>()?.InformationalVersion;
            if (!string.IsNullOrWhiteSpace(informational))
                return informational.Split('+', 2)[0];

            var fileVersion = EntryAssembly.GetCustomAttribute<AssemblyFileVersionAttribute>()?.Version;
            if (!string.IsNullOrWhiteSpace(fileVersion))
                return fileVersion;

            return EntryAssembly.GetName().Version?.ToString(3) ?? "1.0.0";
        }
    }

    public static string BuildLabel
    {
        get
        {
            if (BuildDate == DateTime.MinValue)
                return $"Build {DisplayVersion}";

            return $"Build {DisplayVersion} ({BuildDate.AddHours(8):dd MMM yyyy HH:mm} MYT)";
        }
    }

    public static DateTime BuildDate
    {
        get
        {
            var raw = EntryAssembly
                .GetCustomAttributes<AssemblyMetadataAttribute>()
                .FirstOrDefault(a => a.Key == "BuildDate")?.Value;
            return DateTime.TryParse(raw, null, DateTimeStyles.RoundtripKind, out var dt)
                ? dt
                  : DateTime.MinValue;
        }
    }

    public static string? InstalledPatchCatalogVersion => ReadPatchCatalogMetadata()?.Version;

    public static string? InstalledPatchCatalogLabel => ReadPatchCatalogMetadata()?.Label;

    public static string? InstalledPatchCatalogSummary => ReadPatchCatalogMetadata()?.Summary;

    public static string? InstalledPatchCatalogHash => ReadPatchCatalogMetadata()?.Hash;

    private static InstalledPatchCatalogMetadata? ReadPatchCatalogMetadata()
    {
        try
        {
            var path = Path.Combine(AppContext.BaseDirectory, "patch-catalog.json");
            if (!File.Exists(path))
                return null;

            return JsonSerializer.Deserialize<InstalledPatchCatalogMetadata>(
                File.ReadAllText(path),
                new JsonSerializerOptions { PropertyNameCaseInsensitive = true });
        }
        catch
        {
            return null;
        }
    }

    private sealed class InstalledPatchCatalogMetadata
    {
        public string? Version { get; init; }
        public string? Label { get; init; }
        public string? Summary { get; init; }
        public string? Hash { get; init; }
    }
}
