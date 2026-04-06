using MagDbPatcher.Models;
using MagDbPatcher.Services;
using MagDbPatcher.ViewModels;
using MagDbPatcher.Workflows;
using Xunit;

namespace MagDbPatcher.Tests;

public class PatchRunCoordinatorTests
{
    [Fact]
    public async Task Validate_ReturnsDeterministicIssues_ForMissingInput()
    {
        var root = CreateTempDir();
        try
        {
            var patches = Path.Combine(root, "patches");
            Directory.CreateDirectory(patches);
            await File.WriteAllTextAsync(Path.Combine(patches, "versions.json"), """{ "versions": [], "patches": [] }""");

            var versionService = new VersionService(patches);
            await versionService.LoadVersionsAsync();
            var coordinator = new PatchRunCoordinator(versionService);

            var issues = coordinator.Validate(new PatchRunRequest
            {
                SourceBakPath = "",
                FromVersionId = "",
                ToVersionId = "",
                ConnectionSettings = new SqlConnectionSettings { Server = "" }
            }, requirePassword: true);

            Assert.Contains(issues, i => i.Field == "Source Backup");
            Assert.Contains(issues, i => i.Field == "Versions");
            Assert.Contains(issues, i => i.Field == "SQL Server");
        }
        finally
        {
            TryDelete(root);
        }
    }

    [Fact]
    public async Task Validate_RejectsRemoteServer()
    {
        var root = CreateTempDir();
        try
        {
            var patches = Path.Combine(root, "patches");
            Directory.CreateDirectory(patches);
            await File.WriteAllTextAsync(Path.Combine(patches, "versions.json"), """{ "versions": [], "patches": [] }""");

            var versionService = new VersionService(patches);
            await versionService.LoadVersionsAsync();
            var coordinator = new PatchRunCoordinator(versionService);

            var issues = coordinator.Validate(new PatchRunRequest
            {
                SourceBakPath = "c:\\temp\\a.bak",
                FromVersionId = "6.5",
                ToVersionId = "7.0",
                ConnectionSettings = new SqlConnectionSettings { Server = "10.0.0.1" }
            }, requirePassword: false);

            Assert.Contains(issues, i => i.Field == "SQL Server" && i.Message.Contains("Only local SQL Server", StringComparison.OrdinalIgnoreCase));
        }
        finally
        {
            TryDelete(root);
        }
    }

    [Fact]
    public async Task RunAsync_FailFastFailure_DoesNotUseWarningThresholdAsFailureMechanism()
    {
        var root = CreateTempDir();
        try
        {
            var patches = Path.Combine(root, "patches");
            Directory.CreateDirectory(patches);
            Directory.CreateDirectory(Path.Combine(patches, "2.0"));
            await File.WriteAllTextAsync(Path.Combine(patches, "2.0", "patch.sql"), "SELECT 1;");
            await File.WriteAllTextAsync(Path.Combine(patches, "versions.json"), """
            {
              "versions": [
                { "id": "1.0", "name": "1.0", "upgradesTo": null, "order": 1 },
                { "id": "2.0", "name": "2.0", "upgradesTo": null, "order": 2 }
              ],
              "patches": [
                { "from": "1.0", "to": "2.0", "scripts": ["2.0/patch.sql"] }
              ]
            }
            """);

            var sourceBak = Path.Combine(root, "source.bak");
            await File.WriteAllTextAsync(sourceBak, "fake");

            var versionService = new VersionService(patches);
            await versionService.LoadVersionsAsync();
            var coordinator = new PatchRunCoordinator(
                versionService,
                (settings, progress, warnings, options) => new FailFastFakeSqlServerService(settings, progress, warnings, options));

            var result = await coordinator.RunAsync(
                new PatchRunRequest
                {
                    SourceBakPath = sourceBak,
                    OutputBakPath = Path.Combine(root, "output.bak"),
                    FromVersionId = "1.0",
                    ToVersionId = "2.0",
                    TempFolder = Path.Combine(root, "temp"),
                    ConnectionSettings = new SqlConnectionSettings { Server = "." },
                    ExecutionOptions = new PatchExecutionOptions
                    {
                        ErrorMode = PatchErrorMode.FailFast,
                        WarningThreshold = 1
                    }
                },
                progress: null,
                logProgress: null,
                cancellationToken: CancellationToken.None);

            Assert.False(result.Success);
            Assert.False(result.WarningThresholdExceeded);
            Assert.Equal(0, result.WarningCount);
            Assert.Equal(1, result.WarningThreshold);
        }
        finally
        {
            TryDelete(root);
        }
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

    private sealed class FailFastFakeSqlServerService : SqlServerService
    {
        public FailFastFakeSqlServerService(
            SqlConnectionSettings settings,
            IProgress<string>? progress,
            IProgress<SqlBatchWarning>? warnings,
            PatchExecutionOptions? executionOptions)
            : base(settings, progress, warnings, executionOptions)
        {
        }

        public override Task RestoreDatabaseAsync(string bakFilePath, string databaseName, CancellationToken cancellationToken = default) =>
            Task.CompletedTask;

        public override Task ExecuteScriptAsync(string databaseName, string scriptPath, CancellationToken cancellationToken = default) =>
            throw new InvalidOperationException("Fail-fast script failure.");

        public override Task BackupDatabaseAsync(string databaseName, string outputPath, CancellationToken cancellationToken = default) =>
            Task.CompletedTask;

        public override Task DropDatabaseAsync(string databaseName, CancellationToken cancellationToken = default) =>
            Task.CompletedTask;
    }
}
