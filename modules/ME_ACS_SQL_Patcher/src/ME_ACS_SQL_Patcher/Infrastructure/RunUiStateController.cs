namespace MagDbPatcher.Infrastructure;

public sealed class RunUiStateController
{
    public RunUiState GetState(bool isRunning)
    {
        return new RunUiState
        {
            PatchEnabled = !isRunning,
            CancelEnabled = isRunning,
            BrowseEnabled = !isRunning,
            SourceSelectorEnabled = !isRunning,
            FromSelectorEnabled = !isRunning,
            ToSelectorEnabled = !isRunning,
            PatchToLatestEnabled = !isRunning,
            AdminToolsEnabled = !isRunning,
            CopyPatchPlanEnabled = !isRunning,
            ImportPatchPackEnabled = !isRunning
        };
    }
}

public sealed class RunUiState
{
    public bool PatchEnabled { get; init; }
    public bool CancelEnabled { get; init; }
    public bool BrowseEnabled { get; init; }
    public bool SourceSelectorEnabled { get; init; }
    public bool FromSelectorEnabled { get; init; }
    public bool ToSelectorEnabled { get; init; }
    public bool PatchToLatestEnabled { get; init; }
    public bool AdminToolsEnabled { get; init; }
    public bool CopyPatchPlanEnabled { get; init; }
    public bool ImportPatchPackEnabled { get; init; }
}
