using System.IO;
using MagDbPatcher.Models;

namespace MagDbPatcher.Services;

public class PatchService
{
    private readonly SqlServerService _sqlService;
    private readonly IVersionService _versionService;
    private readonly IProgress<(int percent, string message)> _progress;

    public PatchService(
        SqlServerService sqlService,
        IVersionService versionService,
        IProgress<(int percent, string message)> progress)
    {
        _sqlService = sqlService;
        _versionService = versionService;
        _progress = progress;
    }

    public async Task<string> PatchDatabaseAsync(
        string sourceBakPath,
        string fromVersion,
        string toVersion,
        string outputBakPath,
        string tempFolder,
        CancellationToken cancellationToken = default)
    {
        var tempDbName = $"MagDbPatcher_Temp_{Guid.NewGuid():N}".Substring(0, 30);
        string? tempBakPath = null;
        string? tempOutputPath = null;

        try
        {
            cancellationToken.ThrowIfCancellationRequested();

            if (!Directory.Exists(tempFolder))
            {
                Directory.CreateDirectory(tempFolder);
            }

            await CleanupStaleTempFilesAsync(tempFolder, cancellationToken);

            _progress.Report((4, "Preparing SQL access to temp workspace..."));
            _sqlService.EnsureTempFolderAccess(tempFolder);

            _progress.Report((5, "Copying backup to temp location..."));
            tempBakPath = Path.Combine(tempFolder, $"source_{Guid.NewGuid():N}.bak");
            await CopyFileAsync(sourceBakPath, tempBakPath, cancellationToken);
            cancellationToken.ThrowIfCancellationRequested();

            tempOutputPath = Path.Combine(tempFolder, $"output_{Guid.NewGuid():N}.bak");

            _progress.Report((10, "Calculating upgrade path..."));
            var steps = _versionService.CalculateUpgradePath(fromVersion, toVersion);

            if (steps.Count == 0)
            {
                throw new InvalidOperationException("No upgrade path found.");
            }

            var totalScripts = steps.Sum(s => s.Scripts.Count);
            if (totalScripts <= 0)
            {
                throw new InvalidOperationException("Upgrade path contains no scripts. Check patches/versions.json.");
            }

            foreach (var step in steps)
            {
                if (step.Scripts.Count == 0)
                {
                    throw new InvalidOperationException($"Patch step {step.FromVersion} -> {step.ToVersion} has no scripts configured.");
                }

                foreach (var script in step.Scripts)
                {
                    cancellationToken.ThrowIfCancellationRequested();

                    if (!File.Exists(script))
                    {
                        throw new FileNotFoundException($"Missing script file: {script}", script);
                    }

                    try
                    {
                        using var _ = File.Open(script, FileMode.Open, FileAccess.Read, FileShare.ReadWrite);
                    }
                    catch (Exception ex)
                    {
                        throw new IOException($"Script file is not readable: {script}", ex);
                    }
                }
            }

            var currentScript = 0;

            _progress.Report((15, "Restoring source backup..."));
            await _sqlService.RestoreDatabaseAsync(tempBakPath, tempDbName, cancellationToken);
            cancellationToken.ThrowIfCancellationRequested();

            foreach (var step in steps)
            {
                _progress.Report((20 + (int)(currentScript * 60.0 / totalScripts),
                    $"Upgrading from {step.FromVersion} to {step.ToVersion}..."));

                foreach (var script in step.Scripts)
                {
                    cancellationToken.ThrowIfCancellationRequested();

                    var scriptName = Path.GetFileName(script);
                    _progress.Report((20 + (int)(currentScript * 60.0 / totalScripts),
                        $"Running: {scriptName}"));

                    try
                    {
                        await _sqlService.ExecuteScriptAsync(tempDbName, script, cancellationToken);
                    }
                    catch (OperationCanceledException)
                    {
                        throw;
                    }
                    catch (Exception ex)
                    {
                        throw new InvalidOperationException(
                            $"Failed while running script '{scriptName}' (step {step.FromVersion} -> {step.ToVersion}): {ex.Message}",
                            ex);
                    }

                    currentScript++;
                }
            }

            _progress.Report((85, "Creating output backup..."));
            await _sqlService.BackupDatabaseAsync(tempDbName, tempOutputPath, cancellationToken);
            cancellationToken.ThrowIfCancellationRequested();

            _progress.Report((92, "Copying to output location..."));
            await CopyFileAsync(tempOutputPath, outputBakPath, cancellationToken);

            _progress.Report((95, "Cleaning up..."));
            await _sqlService.DropDatabaseAsync(tempDbName, CancellationToken.None);

            _progress.Report((100, "Patching completed successfully!"));
            return outputBakPath;
        }
        catch (OperationCanceledException)
        {
            await TryDropDatabaseAsync(tempDbName, "cancel");
            throw;
        }
        catch (Exception)
        {
            await TryDropDatabaseAsync(tempDbName, "error");
            throw;
        }
        finally
        {
            TryDeleteFile(tempBakPath, "source temp backup");
            TryDeleteFile(tempOutputPath, "output temp backup");
        }
    }

    private async Task CleanupStaleTempFilesAsync(string tempFolder, CancellationToken cancellationToken)
    {
        try
        {
            await Task.Run(() =>
            {
                var cutoff = DateTime.UtcNow.AddHours(-6);
                var staleFiles = Directory.GetFiles(tempFolder, "*.bak")
                    .Where(path =>
                        Path.GetFileName(path).StartsWith("source_", StringComparison.OrdinalIgnoreCase) ||
                        Path.GetFileName(path).StartsWith("output_", StringComparison.OrdinalIgnoreCase));

                foreach (var file in staleFiles)
                {
                    cancellationToken.ThrowIfCancellationRequested();

                    if (File.GetLastWriteTimeUtc(file) >= cutoff)
                        continue;

                    File.Delete(file);
                    _progress.Report((0, $"Removed stale temp file: {Path.GetFileName(file)}"));
                }
            }, cancellationToken);
        }
        catch (OperationCanceledException)
        {
            throw;
        }
        catch (Exception ex)
        {
            _progress.Report((0, $"WARN: Failed to clean stale temp files: {ex.Message}"));
        }
    }

    private static async Task CopyFileAsync(string sourcePath, string destinationPath, CancellationToken cancellationToken)
    {
        const int BufferSize = 1024 * 128;
        await using var source = new FileStream(
            sourcePath,
            FileMode.Open,
            FileAccess.Read,
            FileShare.Read,
            BufferSize,
            useAsync: true);
        await using var destination = new FileStream(
            destinationPath,
            FileMode.Create,
            FileAccess.Write,
            FileShare.None,
            BufferSize,
            useAsync: true);

        await source.CopyToAsync(destination, BufferSize, cancellationToken);
        await destination.FlushAsync(cancellationToken);
    }

    private async Task TryDropDatabaseAsync(string tempDbName, string phase)
    {
        try
        {
            await _sqlService.DropDatabaseAsync(tempDbName, CancellationToken.None);
        }
        catch (Exception ex)
        {
            _progress.Report((96, $"WARN: Cleanup ({phase}) could not drop temp database: {ex.Message}"));
        }
    }

    private void TryDeleteFile(string? path, string label)
    {
        if (string.IsNullOrWhiteSpace(path) || !File.Exists(path))
            return;

        try
        {
            File.Delete(path);
        }
        catch (Exception ex)
        {
            _progress.Report((96, $"WARN: Cleanup could not remove {label}: {ex.Message}"));
        }
    }
}
