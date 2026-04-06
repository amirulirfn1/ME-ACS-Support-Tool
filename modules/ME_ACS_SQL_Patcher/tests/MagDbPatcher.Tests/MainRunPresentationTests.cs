using MagDbPatcher.Infrastructure;
using MagDbPatcher.Models;
using MagDbPatcher.Services;
using MagDbPatcher.Workflows;
using Xunit;

namespace MagDbPatcher.Tests;

public class MainRunPresentationTests
{
    [Fact]
    public async Task RunSummaryComposer_Compose_ShowsResolvedPlanAndSafeguards()
    {
        var root = CreateTempDir();
        try
        {
            var setup = await CreateMinimalPatchSetupAsync(root);
            var sourceBak = Path.Combine(root, "source.bak");
            var outputBak = Path.Combine(root, "source_patched_2.0.bak");

            var composer = new RunSummaryComposer();
            var state = composer.Compose(new RunSummaryInput(
                SourceBakPath: sourceBak,
                FromVersionId: "1.0",
                ToVersionId: "2.0",
                SqlServer: @".\MAGSQL",
                SqlAuthMode: SqlAuthMode.Windows,
                SqlConnectionTestPassed: true,
                TempFolder: Path.Combine(root, "temp"),
                ErrorMode: PatchErrorMode.FailFast,
                WarningThreshold: 7,
                OutputBakPath: outputBak,
                VersionService: setup));

            Assert.Contains(sourceBak, state.SourceText);
            Assert.Equal(SourceFileHintKind.Success, state.SourceFileHintKind);
            Assert.StartsWith("1.0 -> 2.0", state.UpgradePathText);
            Assert.Contains("1 step(s), 1 script(s)", state.UpgradePathText);
            Assert.Contains("1 step(s), 1 script(s)", state.PlanText);
            Assert.Contains(@"Server: .\MAGSQL", state.ConnectionText);
            Assert.Contains("Connection: Tested successfully", state.ConnectionText);
            Assert.Equal(outputBak, state.OutputText);
            Assert.Contains("Mode: Fail fast on SQL errors", state.SafeguardsText);
            Assert.Contains("Warning threshold: 7", state.SafeguardsText);
        }
        finally
        {
            TryDelete(root);
        }
    }

    [Fact]
    public void RunRequestBuilder_BuildOutputBakPath_UsesTargetVersionSuffix()
    {
        var builder = new RunRequestBuilder();
        var output = builder.BuildOutputBakPath(@"C:\backups\source.bak", "7.2.3-20260123");

        Assert.Equal(@"C:\backups\source_patched_7.2.3-20260123.bak", output);
    }

    [Fact]
    public void RunRequestBuilder_Build_UsesMachineSafeTempFolderByDefault()
    {
        var paths = TestAppPaths.Create(@"C:\PortablePatcher");
        var builder = new RunRequestBuilder(paths);

        var request = builder.Build(
            @"C:\backups\source.bak",
            "7.0",
            "7.2",
            new AppSettings(),
            new SqlConnectionSettings { Server = @".\MAGSQL", AuthMode = SqlAuthMode.Windows });

        Assert.Equal(paths.TempFolder, request.TempFolder);
    }

    [Fact]
    public void RunRequestBuilder_Build_MigratesLegacyPortableTempFolder()
    {
        var paths = TestAppPaths.Create(@"C:\PortablePatcher");
        var builder = new RunRequestBuilder(paths);

        var request = builder.Build(
            @"C:\backups\source.bak",
            "7.0",
            "7.2",
            new AppSettings { PatchTempFolder = Path.Combine(paths.RootDirectory, "temp") },
            new SqlConnectionSettings { Server = @".\MAGSQL", AuthMode = SqlAuthMode.Windows });

        Assert.Equal(paths.TempFolder, request.TempFolder);
    }

    [Fact]
    public void SqlConnectionTestCoordinator_InvalidatesAfterSettingsChange()
    {
        var coordinator = new SqlConnectionTestCoordinator();
        var baseline = new SqlConnectionSettings
        {
            Server = @".\MAGSQL",
            AuthMode = SqlAuthMode.SqlLogin,
            Username = "sa",
            Password = "secret"
        };

        var feedback = coordinator.RegisterSuccess(baseline);
        Assert.True(feedback.Passed);
        Assert.True(coordinator.IsConnectionTestPassed);

        coordinator.InvalidateIfSettingsChanged(SqlConnectionTestCoordinator.BuildSignature(new SqlConnectionSettings
        {
            Server = @".\MAGSQL",
            AuthMode = SqlAuthMode.SqlLogin,
            Username = "sa",
            Password = "different"
        }));

        Assert.False(coordinator.IsConnectionTestPassed);
    }

    [Fact]
    public void RunExecutionPresenter_BuildProgressState_ShowsPhaseScriptsAndWarnings()
    {
        var presenter = new RunExecutionPresenter();
        var state = presenter.BuildProgressState(new PatchRunProgress
        {
            Percent = 48,
            Message = "Running: patch.sql (Script 2/4)",
            FlowState = ViewModels.PatchFlowState.Run,
            CurrentScript = 2,
            TotalScripts = 4,
            WarningCount = 3
        });

        Assert.Equal(48, state.ProgressValue);
        Assert.Contains("Phase: Script execution", state.DetailText);
        Assert.Contains("Scripts: 2/4", state.DetailText);
        Assert.Contains("Warnings: 3", state.DetailText);
    }

    [Fact]
    public void AdminVersionChainFormatter_FormatsVersionChain()
    {
        var formatter = new AdminVersionChainFormatter();
        var text = formatter.Format(new[]
        {
            new VersionInfo { Id = "6.5" },
            new VersionInfo { Id = "7.0" },
            new VersionInfo { Id = "7.2.3-20260123" }
        });

        Assert.Equal("6.5  ->  7.0  ->  7.2.3-20260123", text);
    }

    [Fact]
    public void RunWarningFormatter_GroupsRepeatedWarningsIntoReadableCards()
    {
        var formatter = new RunWarningFormatter();
        var warnings = new[]
        {
            new SqlBatchWarning("patch.sql", 2, 36, 1781, "Column already has a DEFAULT bound to it.", "ALTER TABLE ..."),
            new SqlBatchWarning("patch.sql", 3, 36, 1781, "Column already has a DEFAULT bound to it.", "ALTER TABLE ..."),
            new SqlBatchWarning("patch.sql", 4, 36, 1781, "Column already has a DEFAULT bound to it.", "ALTER TABLE ..."),
            new SqlBatchWarning("other.sql", 1, 5, 2627, "Violation of PRIMARY KEY constraint.", "INSERT ...")
        };

        var items = formatter.BuildItems(warnings);

        Assert.Equal(2, items.Count);
        Assert.Equal("SQL 1781 in patch.sql", items[0].Title);
        Assert.Contains("3 batches affected: 2, 3, 4 of 36", items[0].Subtitle);
        Assert.Equal("Column already has a DEFAULT bound to it.", items[0].Details);
        Assert.Equal("SQL 2627 in other.sql", items[1].Title);
    }

    [Fact]
    public void DiagnosticsComposer_BuildDiagnostics_ProducesStructuredWarningSummary()
    {
        var composer = new DiagnosticsComposer();
        var text = composer.BuildDiagnostics(
            status: "Completed",
            resultSummary: "Completed with warnings",
            runWarnings: new[]
            {
                new SqlBatchWarning("patch.sql", 2, 36, 1781, "Column already has a DEFAULT bound to it.", "ALTER TABLE ..."),
                new SqlBatchWarning("patch.sql", 3, 36, 1781, "Column already has a DEFAULT bound to it.", "ALTER TABLE ...")
            },
            runtimeLog: "[10:11:16] Running patch",
            patchPlan: "1.0 -> 2.0",
            nonFatalDiagnostics: new[] { "Catalog warning" });

        Assert.Contains("Warnings", text);
        Assert.Contains("Total SQL warnings: 2", text);
        Assert.Contains("Unique warning groups: 1", text);
        Assert.Contains("1. SQL 1781 in patch.sql", text);
        Assert.Contains("Runtime Log", text);
        Assert.Contains("Non-Fatal Diagnostics", text);
    }

    private static async Task<VersionService> CreateMinimalPatchSetupAsync(string root)
    {
        var patches = Path.Combine(root, "patches");
        Directory.CreateDirectory(patches);
        Directory.CreateDirectory(Path.Combine(patches, "2.0"));
        await File.WriteAllTextAsync(Path.Combine(patches, "2.0", "patch.sql"), "SELECT 1;");

        var json = """
                   {
                     "versions": [
                       { "id": "1.0", "name": "1.0", "upgradesTo": null, "order": 1 },
                       { "id": "2.0", "name": "2.0", "upgradesTo": null, "order": 2 }
                     ],
                     "patches": [
                       { "from": "1.0", "to": "2.0", "scripts": ["2.0/patch.sql"] }
                     ]
                   }
                   """;
        await File.WriteAllTextAsync(Path.Combine(patches, "versions.json"), json);
        await File.WriteAllTextAsync(Path.Combine(root, "source.bak"), "fake-backup");

        var versionService = new VersionService(patches);
        await versionService.LoadVersionsAsync();
        return versionService;
    }

    private static string CreateTempDir()
    {
        var path = Path.Combine(Path.GetTempPath(), "MagDbPatcher.Tests", Guid.NewGuid().ToString("N"));
        Directory.CreateDirectory(path);
        return path;
    }

    private static void TryDelete(string path)
    {
        try { Directory.Delete(path, true); } catch { }
    }
}
