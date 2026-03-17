namespace MEACSSupportTool.Models;

public sealed class HistoryRecord
{
    public required string RunId { get; init; }

    public required string ActionId { get; init; }

    public required string ActionName { get; init; }

    public required string MachineName { get; init; }

    public required string UserName { get; init; }

    public required DateTime StartedAt { get; init; }

    public required DateTime EndedAt { get; init; }

    public required RunOutcome Outcome { get; init; }

    public required string Summary { get; init; }

    public required string LogFilePath { get; init; }
}
