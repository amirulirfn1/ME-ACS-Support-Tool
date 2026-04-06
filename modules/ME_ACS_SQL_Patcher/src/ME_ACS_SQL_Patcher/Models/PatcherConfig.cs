using System.Text.Json.Serialization;

namespace MagDbPatcher.Models;

public class PatcherConfig
{
    public int SchemaVersion { get; set; } = 1;
    public VersionOrderingConfig VersionOrdering { get; set; } = new();
    public AutoGenerateConfig AutoGenerate { get; set; } = new();
}

public class VersionOrderingConfig
{
    public string Mode { get; set; } = "semantic_with_optional_buildDate";
}

public class AutoGenerateConfig
{
    public string BuildVersionPattern { get; set; } = "-";
    public List<AutoGenerateRule> Rules { get; set; } = new();
}

public class AutoGenerateRule
{
    public string Type { get; set; } = "";

    [JsonPropertyName("from")]
    public List<string>? FromVersions { get; set; }

    public int? ToMajor { get; set; }
}

