namespace MagDbPatcher.Infrastructure;

public sealed class AdminUiStateController
{
    public AdminUiState GetState(
        bool hasVersionSelection,
        bool hasVersionScriptSelection,
        bool hasPatchSelection,
        bool hasStagedLinkSelection,
        bool hasStagedChanges)
    {
        return new AdminUiState
        {
            EditVersionEnabled = hasVersionSelection,
            DeleteVersionEnabled = hasVersionSelection,
            AddScriptEnabled = hasVersionSelection,
            RemoveScriptEnabled = hasVersionSelection && hasVersionScriptSelection,
            EditPatchEnabled = hasPatchSelection,
            DeletePatchEnabled = hasPatchSelection,
            RemoveStagedLinkEnabled = hasStagedLinkSelection,
            ApplyCatalogEnabled = hasStagedChanges
        };
    }
}

public sealed class AdminUiState
{
    public bool EditVersionEnabled { get; init; }
    public bool DeleteVersionEnabled { get; init; }
    public bool AddScriptEnabled { get; init; }
    public bool RemoveScriptEnabled { get; init; }
    public bool EditPatchEnabled { get; init; }
    public bool DeletePatchEnabled { get; init; }
    public bool RemoveStagedLinkEnabled { get; init; }
    public bool ApplyCatalogEnabled { get; init; }
}
