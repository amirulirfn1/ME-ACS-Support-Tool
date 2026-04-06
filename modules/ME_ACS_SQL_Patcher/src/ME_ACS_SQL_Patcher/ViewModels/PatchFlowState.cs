namespace MagDbPatcher.ViewModels;

public enum PatchFlowState
{
    SelectSource,
    SelectVersions,
    ValidateSql,
    ConfirmPlan,
    Run,
    Result
}
