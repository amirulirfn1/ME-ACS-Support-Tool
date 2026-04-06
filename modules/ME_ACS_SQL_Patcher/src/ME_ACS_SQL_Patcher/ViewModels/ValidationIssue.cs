namespace MagDbPatcher.ViewModels;

public enum ValidationSeverity
{
    Info,
    Warning,
    Error
}

public enum NotificationLevel
{
    None,
    Info,
    Success,
    Error
}

public sealed class ValidationIssue
{
    public string Field { get; init; } = "";
    public string Message { get; init; } = "";
    public ValidationSeverity Severity { get; init; } = ValidationSeverity.Error;

    public override string ToString() => $"{Field}: {Message}";
}
