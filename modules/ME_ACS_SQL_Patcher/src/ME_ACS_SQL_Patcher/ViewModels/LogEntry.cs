namespace MagDbPatcher.ViewModels;

public enum LogSeverity { Info, Warning, Error }

public record LogEntry(string Text, LogSeverity Severity);
