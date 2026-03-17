namespace MEACSSupportTool.Models;

public sealed class RunResult
{
    public required RunOutcome Outcome { get; init; }

    public required string Summary { get; init; }
}
