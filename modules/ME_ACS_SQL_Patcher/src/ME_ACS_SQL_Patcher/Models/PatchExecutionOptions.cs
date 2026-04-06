namespace MagDbPatcher.Models;

public enum PatchErrorMode
{
    WarnAndContinue = 0,
    FailFast = 1
}

public sealed class PatchExecutionOptions
{
    public PatchErrorMode ErrorMode { get; init; } = PatchErrorMode.WarnAndContinue;
    public int WarningThreshold { get; init; } = 10;
}
