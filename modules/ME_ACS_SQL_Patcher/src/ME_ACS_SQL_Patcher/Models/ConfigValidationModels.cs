namespace MagDbPatcher.Models;

public enum ConfigIssueSeverity
{
    Warning,
    Error
}

public record ConfigIssue(ConfigIssueSeverity Severity, string Message);

public class ConfigValidationResult
{
    public List<ConfigIssue> Warnings { get; } = new();
    public List<ConfigIssue> Errors { get; } = new();

    public bool HasErrors => Errors.Count > 0;
    public bool HasWarnings => Warnings.Count > 0;
}

