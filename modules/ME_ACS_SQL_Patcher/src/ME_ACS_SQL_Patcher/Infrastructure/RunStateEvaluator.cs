namespace MagDbPatcher.Infrastructure;

public sealed record RunStateInput(
    bool SourcePathEntered,
    bool SourceExists,
    bool VersionSelectionPresent,
    bool VersionPathValid,
    bool LocalSqlServer,
    bool HasSqlUser,
    bool HasSqlPassword,
    bool SqlConnectionTestPassed,
    bool RunEngineReady);

public sealed class RunStateEvaluator
{
    public StepGuidanceState Evaluate(RunStateInput input)
    {
        var step1 = input.SourceExists
            ? RunStepState.Done
            : input.SourcePathEntered ? RunStepState.NeedsAttention : RunStepState.Pending;

        var step2 = input.VersionPathValid
            ? RunStepState.Done
            : input.VersionSelectionPresent ? RunStepState.NeedsAttention : RunStepState.Pending;

        var basicConnectionReady = input.LocalSqlServer && input.HasSqlUser && input.HasSqlPassword;
        var step3 = input.SqlConnectionTestPassed && basicConnectionReady
            ? RunStepState.Done
            : basicConnectionReady ? RunStepState.Ready : RunStepState.NeedsAttention;

        var runReady = input.SourceExists &&
                       input.VersionPathValid &&
                       input.SqlConnectionTestPassed &&
                       basicConnectionReady &&
                       input.RunEngineReady;

        var step4Started = input.SourcePathEntered || input.VersionSelectionPresent || basicConnectionReady;
        var step4 = runReady
            ? RunStepState.Ready
            : step4Started ? RunStepState.NeedsAttention : RunStepState.Pending;

        return new StepGuidanceState(
            step1,
            step2,
            step3,
            step4,
            runReady,
            GetNextActionText(input.SourceExists, input.VersionPathValid, basicConnectionReady, input.SqlConnectionTestPassed),
            GetPatchHint(input.SourceExists, input.VersionPathValid, basicConnectionReady, input.SqlConnectionTestPassed));
    }

    public static string GetStepText(RunStepState state) => state switch
    {
        RunStepState.Done => "Done",
        RunStepState.Ready => "Ready",
        RunStepState.NeedsAttention => "Needs Attention",
        _ => "Pending"
    };

    private static string GetNextActionText(bool sourceDone, bool versionsDone, bool basicConnectionReady, bool sqlTestPassed)
    {
        if (!sourceDone)
            return "Next: Select a source backup file.";
        if (!versionsDone)
            return "Next: Choose the target version.";
        if (!basicConnectionReady)
            return "Next: Complete SQL connection details.";
        if (!sqlTestPassed)
            return "Next: Click Test SQL connection.";
        return "Next: Click Start Patch.";
    }

    private static string GetPatchHint(bool sourceDone, bool versionsDone, bool basicConnectionReady, bool sqlTestPassed)
    {
        if (!sourceDone)
            return "Complete Step 1 to continue.";
        if (!versionsDone)
            return "Complete Step 2 to continue.";
        if (!basicConnectionReady || !sqlTestPassed)
            return "Complete Step 3 (Test SQL) to continue.";
        return "Review details and continue.";
    }
}
