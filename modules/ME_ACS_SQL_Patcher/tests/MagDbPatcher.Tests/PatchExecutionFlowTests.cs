using MagDbPatcher.Models;
using MagDbPatcher.Services;
using MagDbPatcher.Workflows;
using Xunit;

namespace MagDbPatcher.Tests;

public class PatchExecutionFlowTests
{
    [Fact]
    public async Task PatchService_UsesRequestedTempFolder_AndCleansStaleTempFiles()
    {
        var root = CreateTempDir();
        try
        {
            var setup = await CreateMinimalPatchSetupAsync(root);
            var tempFolder = Path.Combine(root, "custom-temp");
            Directory.CreateDirectory(tempFolder);

            var staleFile = Path.Combine(tempFolder, "source_stale.bak");
            await File.WriteAllTextAsync(staleFile, "stale");
            File.SetLastWriteTimeUtc(staleFile, DateTime.UtcNow.AddHours(-10));

            var sql = new FakeSqlServerService(
                new SqlConnectionSettings { Server = "." },
                progress: null,
                warnings: null,
                executionOptions: new PatchExecutionOptions());

            var progress = new Progress<(int percent, string message)>(_ => { });
            var patchService = new PatchService(sql, setup.VersionService, progress);
            var outputPath = Path.Combine(root, "patched-output.bak");

            var resultPath = await patchService.PatchDatabaseAsync(
                setup.SourceBakPath,
                "1.0",
                "2.0",
                outputPath,
                tempFolder,
                CancellationToken.None);

            Assert.Equal(outputPath, resultPath);
            Assert.NotNull(sql.RestoredBakPath);
            Assert.StartsWith(Path.GetFullPath(tempFolder), Path.GetFullPath(sql.RestoredBakPath!), StringComparison.OrdinalIgnoreCase);
            Assert.NotNull(sql.BackupOutputPath);
            Assert.StartsWith(Path.GetFullPath(tempFolder), Path.GetFullPath(sql.BackupOutputPath!), StringComparison.OrdinalIgnoreCase);
            Assert.False(File.Exists(staleFile));
            Assert.True(File.Exists(outputPath));
        }
        finally
        {
            TryDelete(root);
        }
    }

    [Fact]
    public async Task PatchRunCoordinator_ReturnsStructuredWarningMetadata()
    {
        var root = CreateTempDir();
        try
        {
            var setup = await CreateMinimalPatchSetupAsync(root);
            var tempFolder = Path.Combine(root, "temp");
            Directory.CreateDirectory(tempFolder);
            var outputPath = Path.Combine(root, "patched-output.bak");

            var coordinator = new PatchRunCoordinator(
                setup.VersionService,
                (settings, progress, warnings, options) =>
                {
                    var fake = new FakeSqlServerService(settings, progress, warnings, options)
                    {
                        EmitSingleWarning = true
                    };
                    return fake;
                });

            var result = await coordinator.RunAsync(
                new PatchRunRequest
                {
                    SourceBakPath = setup.SourceBakPath,
                    OutputBakPath = outputPath,
                    FromVersionId = "1.0",
                    ToVersionId = "2.0",
                    TempFolder = tempFolder,
                    ConnectionSettings = new SqlConnectionSettings { Server = "." },
                    ExecutionOptions = new PatchExecutionOptions { ErrorMode = PatchErrorMode.WarnAndContinue }
                },
                progress: null,
                logProgress: null,
                cancellationToken: CancellationToken.None);

            Assert.True(result.Success);
            Assert.Equal(1, result.WarningCount);
            Assert.Single(result.Warnings);
            Assert.True(result.WarningCountsBySqlError.TryGetValue(2714, out var count));
            Assert.Equal(1, count);
            Assert.True(File.Exists(outputPath));
        }
        finally
        {
            TryDelete(root);
        }
    }

    [Fact]
    public async Task PatchRunCoordinator_MarksThresholdExceeded_WithoutFailingRun()
    {
        var root = CreateTempDir();
        try
        {
            var setup = await CreateMinimalPatchSetupAsync(root);
            var tempFolder = Path.Combine(root, "temp");
            Directory.CreateDirectory(tempFolder);
            var outputPath = Path.Combine(root, "patched-output.bak");

            var coordinator = new PatchRunCoordinator(
                setup.VersionService,
                (settings, progress, warnings, options) =>
                    new FakeSqlServerService(settings, progress, warnings, options)
                    {
                        WarningCountToEmit = 2
                    });

            var result = await coordinator.RunAsync(
                new PatchRunRequest
                {
                    SourceBakPath = setup.SourceBakPath,
                    OutputBakPath = outputPath,
                    FromVersionId = "1.0",
                    ToVersionId = "2.0",
                    TempFolder = tempFolder,
                    ConnectionSettings = new SqlConnectionSettings { Server = "." },
                    ExecutionOptions = new PatchExecutionOptions
                    {
                        ErrorMode = PatchErrorMode.WarnAndContinue,
                        WarningThreshold = 1
                    }
                },
                progress: null,
                logProgress: null,
                cancellationToken: CancellationToken.None);

            Assert.True(result.Success);
            Assert.True(result.WarningThresholdExceeded);
            Assert.Equal(1, result.WarningThreshold);
            Assert.Equal(2, result.WarningCount);
        }
        finally
        {
            TryDelete(root);
        }
    }

    [Theory]
    [InlineData("restore")]
    [InlineData("script")]
    [InlineData("backup")]
    public async Task PatchService_RespectsCancellation_AcrossPhases(string phase)
    {
        var root = CreateTempDir();
        try
        {
            var setup = await CreateMinimalPatchSetupAsync(root);
            var tempFolder = Path.Combine(root, "temp");
            Directory.CreateDirectory(tempFolder);
            var outputPath = Path.Combine(root, "patched-output.bak");
            using var cts = new CancellationTokenSource();

            var sql = new FakeSqlServerService(
                new SqlConnectionSettings { Server = "." },
                progress: null,
                warnings: null,
                executionOptions: new PatchExecutionOptions())
            {
                PhaseReached = p =>
                {
                    if (string.Equals(p, phase, StringComparison.OrdinalIgnoreCase))
                        cts.Cancel();
                }
            };

            var progress = new Progress<(int percent, string message)>(_ => { });
            var patchService = new PatchService(sql, setup.VersionService, progress);

            await Assert.ThrowsAnyAsync<OperationCanceledException>(() =>
                patchService.PatchDatabaseAsync(
                    setup.SourceBakPath,
                    "1.0",
                    "2.0",
                    outputPath,
                    tempFolder,
                    cts.Token));

            Assert.True(sql.DropDatabaseCallCount >= 1);
        }
        finally
        {
            TryDelete(root);
        }
    }

    private static async Task<(VersionService VersionService, string SourceBakPath)> CreateMinimalPatchSetupAsync(string root)
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

        var sourceBakPath = Path.Combine(root, "source.bak");
        await File.WriteAllTextAsync(sourceBakPath, "fake-backup");

        var versionService = new VersionService(patches);
        await versionService.LoadVersionsAsync();

        return (versionService, sourceBakPath);
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

    private sealed class FakeSqlServerService : SqlServerService
    {
        private bool _warningEmitted;

        public FakeSqlServerService(
            SqlConnectionSettings settings,
            IProgress<string>? progress,
            IProgress<SqlBatchWarning>? warnings,
            PatchExecutionOptions? executionOptions)
            : base(settings, progress, warnings, executionOptions)
        {
        }

        public string? RestoredBakPath { get; private set; }

        public string? BackupOutputPath { get; private set; }

        public bool EmitSingleWarning { get; init; }
        public int WarningCountToEmit { get; init; }
        public bool ThrowOnScript { get; init; }
        public Action<string>? PhaseReached { get; init; }
        public int DropDatabaseCallCount { get; private set; }

        public override Task<bool> TestConnectionAsync(CancellationToken cancellationToken = default) => Task.FromResult(true);

        public override Task RestoreDatabaseAsync(string bakFilePath, string databaseName, CancellationToken cancellationToken = default)
        {
            PhaseReached?.Invoke("restore");
            cancellationToken.ThrowIfCancellationRequested();
            RestoredBakPath = bakFilePath;
            return Task.CompletedTask;
        }

        public override Task ExecuteScriptAsync(string databaseName, string scriptPath, CancellationToken cancellationToken = default)
        {
            PhaseReached?.Invoke("script");
            cancellationToken.ThrowIfCancellationRequested();

            if (ThrowOnScript)
                throw new InvalidOperationException("Injected script failure.");

            if (EmitSingleWarning && !_warningEmitted)
            {
                EmitWarning(new SqlBatchWarning(
                    Path.GetFileName(scriptPath),
                    1,
                    1,
                    2714,
                    "There is already an object named in the database.",
                    "CREATE TABLE dbo.Test (Id int);"));
                _warningEmitted = true;
            }

            for (var i = 0; i < WarningCountToEmit; i++)
            {
                EmitWarning(new SqlBatchWarning(
                    Path.GetFileName(scriptPath),
                    i + 1,
                    WarningCountToEmit,
                    2714,
                    "There is already an object named in the database.",
                    "CREATE TABLE dbo.Test (Id int);"));
            }

            return Task.CompletedTask;
        }

        public override Task BackupDatabaseAsync(string databaseName, string outputPath, CancellationToken cancellationToken = default)
        {
            PhaseReached?.Invoke("backup");
            cancellationToken.ThrowIfCancellationRequested();
            BackupOutputPath = outputPath;
            File.WriteAllText(outputPath, "patched-backup");
            return Task.CompletedTask;
        }

        public override Task DropDatabaseAsync(string databaseName, CancellationToken cancellationToken = default)
        {
            DropDatabaseCallCount++;
            return Task.CompletedTask;
        }
    }
}
