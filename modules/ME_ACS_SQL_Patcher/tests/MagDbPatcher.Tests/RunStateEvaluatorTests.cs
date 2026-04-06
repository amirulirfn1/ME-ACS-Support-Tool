using MagDbPatcher.Infrastructure;
using Xunit;

namespace MagDbPatcher.Tests;

public class RunStateEvaluatorTests
{
    private readonly RunStateEvaluator _evaluator = new();

    [Fact]
    public void Evaluate_AllPrerequisitesSatisfied_MarksRunReady()
    {
        var state = _evaluator.Evaluate(new RunStateInput(
            SourcePathEntered: true,
            SourceExists: true,
            VersionSelectionPresent: true,
            VersionPathValid: true,
            LocalSqlServer: true,
            HasSqlUser: true,
            HasSqlPassword: true,
            SqlConnectionTestPassed: true,
            RunEngineReady: true));

        Assert.Equal(RunStepState.Done, state.Step1State);
        Assert.Equal(RunStepState.Done, state.Step2State);
        Assert.Equal(RunStepState.Done, state.Step3State);
        Assert.Equal(RunStepState.Ready, state.Step4State);
        Assert.True(state.RunReady);
        Assert.Equal("Next: Click Start Patch.", state.NextActionText);
    }

    [Fact]
    public void Evaluate_PartialProgressWithoutReadiness_Step4NeedsAttention()
    {
        var state = _evaluator.Evaluate(new RunStateInput(
            SourcePathEntered: true,
            SourceExists: true,
            VersionSelectionPresent: true,
            VersionPathValid: true,
            LocalSqlServer: true,
            HasSqlUser: true,
            HasSqlPassword: true,
            SqlConnectionTestPassed: false,
            RunEngineReady: true));

        Assert.Equal(RunStepState.NeedsAttention, state.Step4State);
        Assert.False(state.RunReady);
        Assert.Equal("Next: Click Test SQL connection.", state.NextActionText);
        Assert.Equal("Complete Step 3 (Test SQL) to continue.", state.PatchHintText);
    }
}
