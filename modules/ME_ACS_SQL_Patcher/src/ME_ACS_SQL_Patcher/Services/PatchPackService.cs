using System;
using System.Collections.Generic;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Reflection;
using System.Text.Json;
using MagDbPatcher.Models;

namespace MagDbPatcher.Services;

public class PatchPackService
{
    private readonly string? _backupRootDirectory;
    private readonly string? _importArchiveDirectory;

    public PatchPackService(string? backupRootDirectory = null, string? importArchiveDirectory = null)
    {
        _backupRootDirectory = string.IsNullOrWhiteSpace(backupRootDirectory)
            ? null
            : Path.GetFullPath(backupRootDirectory);
        _importArchiveDirectory = string.IsNullOrWhiteSpace(importArchiveDirectory)
            ? null
            : Path.GetFullPath(importArchiveDirectory);
    }

    public record ImportResult(PatchPackManifest Manifest, string BackupFolder, string? ArchivedPackPath);

    public async Task<ImportResult> ImportAsync(string zipPath, string targetPatchesFolder)
    {
        if (string.IsNullOrWhiteSpace(zipPath))
            throw new ArgumentException("Zip path is required.", nameof(zipPath));
        if (!File.Exists(zipPath))
            throw new FileNotFoundException("Patch pack zip not found.", zipPath);
        if (string.IsNullOrWhiteSpace(targetPatchesFolder))
            throw new ArgumentException("Target patches folder is required.", nameof(targetPatchesFolder));

        var appVersion = Assembly.GetExecutingAssembly().GetName().Version ?? new Version(1, 0, 0);

        PatchPackManifest manifest;
        using (var stream = File.OpenRead(zipPath))
        using (var zip = new ZipArchive(stream, ZipArchiveMode.Read, leaveOpen: false))
        {
            manifest = await ValidateZipAsync(zip, appVersion);
        }

        var tempRoot = CreateTempRootNearTarget(targetPatchesFolder);
        try
        {
            using (var stream = File.OpenRead(zipPath))
            using (var zip = new ZipArchive(stream, ZipArchiveMode.Read, leaveOpen: false))
            {
                ExtractZip(zip, tempRoot);
            }

            var extractedPatchesFolder = Path.Combine(tempRoot, manifest.ContentRoot);
            await ValidateExtractedPatchesAsync(extractedPatchesFolder);

            var archivedPack = ArchiveImportedPack(zipPath, manifest);
            var backup = AtomicSwap(targetPatchesFolder, extractedPatchesFolder, _backupRootDirectory);
            return new ImportResult(manifest, backup, archivedPack);
        }
        finally
        {
            TryDeleteDirectory(tempRoot);
        }
    }

    private static async Task<PatchPackManifest> ValidateZipAsync(ZipArchive zip, Version appVersion)
    {
        var entry = zip.GetEntry("patch-pack.json");
        if (entry == null)
            throw new InvalidOperationException("Invalid patch pack: missing patch-pack.json.");

        PatchPackManifest? manifest;
        await using (var s = entry.Open())
        {
            var options = new JsonSerializerOptions { PropertyNameCaseInsensitive = true };
            manifest = await JsonSerializer.DeserializeAsync<PatchPackManifest>(s, options);
        }

        if (manifest == null)
            throw new InvalidOperationException("Invalid patch pack: patch-pack.json is unreadable.");

        if (manifest.SchemaVersion != 1)
            throw new InvalidOperationException($"Unsupported patch pack schemaVersion '{manifest.SchemaVersion}'. Expected 1.");

        if (string.IsNullOrWhiteSpace(manifest.ContentRoot))
            manifest.ContentRoot = "patches";

        if (!string.Equals(manifest.ContentRoot, "patches", StringComparison.OrdinalIgnoreCase))
            throw new InvalidOperationException($"Unsupported contentRoot '{manifest.ContentRoot}'. Expected 'patches'.");

        if (string.IsNullOrWhiteSpace(manifest.PackVersion))
            throw new InvalidOperationException("Invalid patch pack: packVersion is required.");

        if (!Version.TryParse(manifest.MinAppVersion, out var minApp))
            throw new InvalidOperationException($"Invalid patch pack: minAppVersion '{manifest.MinAppVersion}' is not a valid version.");

        if (appVersion < minApp)
            throw new InvalidOperationException($"Patch pack requires app version {minApp} or newer. Current app version is {appVersion}.");

        if (zip.GetEntry($"{manifest.ContentRoot}/versions.json") == null)
            throw new InvalidOperationException($"Invalid patch pack: missing {manifest.ContentRoot}/versions.json.");

        return manifest;
    }

    private static void ExtractZip(ZipArchive zip, string destinationRoot)
    {
        Directory.CreateDirectory(destinationRoot);
        var rootFull = EnsureTrailingSeparator(Path.GetFullPath(destinationRoot));

        foreach (var entry in zip.Entries)
        {
            if (string.IsNullOrWhiteSpace(entry.FullName))
                continue;

            if (entry.FullName.EndsWith("/", StringComparison.Ordinal) ||
                entry.FullName.EndsWith("\\", StringComparison.Ordinal))
            {
                continue;
            }

            var rel = entry.FullName.Replace('/', Path.DirectorySeparatorChar).Replace('\\', Path.DirectorySeparatorChar);

            if (Path.IsPathRooted(rel) || rel.Contains(':'))
                throw new InvalidOperationException($"Invalid zip entry path: {entry.FullName}");

            var dest = Path.GetFullPath(Path.Combine(destinationRoot, rel));
            if (!dest.StartsWith(rootFull, StringComparison.OrdinalIgnoreCase))
                throw new InvalidOperationException($"Unsafe zip entry path (zip-slip): {entry.FullName}");

            var dir = Path.GetDirectoryName(dest);
            if (!string.IsNullOrWhiteSpace(dir))
                Directory.CreateDirectory(dir);

            entry.ExtractToFile(dest, overwrite: true);
        }
    }

    private static async Task ValidateExtractedPatchesAsync(string patchesFolder)
    {
        if (!Directory.Exists(patchesFolder))
            throw new InvalidOperationException("Invalid patch pack: extracted patches folder is missing.");

        var versionsJson = Path.Combine(patchesFolder, "versions.json");
        if (!File.Exists(versionsJson))
            throw new InvalidOperationException("Invalid patch pack: extracted versions.json is missing.");

        var svc = new VersionService(patchesFolder);
        await svc.LoadVersionsAsync();

        if (svc.LastValidationResult.HasErrors)
        {
            var lines = new List<string> { "Patch pack validation failed:" };
            lines.AddRange(svc.LastValidationResult.Errors.Select(e => $" - {e.Message}"));
            throw new InvalidOperationException(string.Join("\n", lines));
        }
    }

    private static string AtomicSwap(string targetPatchesFolder, string extractedPatchesFolder, string? backupRootDirectory)
    {
        var targetFull = Path.GetFullPath(targetPatchesFolder);
        var parent = Path.GetDirectoryName(targetFull);
        if (string.IsNullOrWhiteSpace(parent))
            throw new InvalidOperationException("Cannot determine target patches folder parent directory.");

        Directory.CreateDirectory(parent);

        var backupBase = string.IsNullOrWhiteSpace(backupRootDirectory)
            ? parent
            : backupRootDirectory;
        Directory.CreateDirectory(backupBase);

        var backupName = $"{Path.GetFileName(targetFull)}_{DateTime.Now:yyyyMMdd_HHmmss}";
        var backup = Path.Combine(backupBase, backupName);

        if (Directory.Exists(targetFull))
        {
            Directory.Move(targetFull, backup);
        }

        try
        {
            Directory.Move(extractedPatchesFolder, targetFull);
            return backup;
        }
        catch
        {
            try
            {
                if (Directory.Exists(targetFull))
                    Directory.Delete(targetFull, recursive: true);
            }
            catch
            {
            }

            try
            {
                if (Directory.Exists(backup) && !Directory.Exists(targetFull))
                    Directory.Move(backup, targetFull);
            }
            catch
            {
            }

            throw;
        }
    }

    private static string CreateTempRootNearTarget(string targetPatchesFolder)
    {
        var targetFull = Path.GetFullPath(targetPatchesFolder);
        var parent = Path.GetDirectoryName(targetFull);
        if (string.IsNullOrWhiteSpace(parent))
            throw new InvalidOperationException("Cannot determine target patches folder parent directory.");

        Directory.CreateDirectory(parent);

        var tempRoot = Path.Combine(parent, $"{Path.GetFileName(targetFull)}_import_tmp_{Guid.NewGuid():N}");
        Directory.CreateDirectory(tempRoot);
        return tempRoot;
    }

    private static void TryDeleteDirectory(string path)
    {
        try
        {
            if (Directory.Exists(path))
                Directory.Delete(path, recursive: true);
        }
        catch
        {
        }
    }

    private static string EnsureTrailingSeparator(string path)
        => path.EndsWith(Path.DirectorySeparatorChar) ? path : path + Path.DirectorySeparatorChar;

    private string? ArchiveImportedPack(string zipPath, PatchPackManifest manifest)
    {
        if (string.IsNullOrWhiteSpace(_importArchiveDirectory))
            return null;

        Directory.CreateDirectory(_importArchiveDirectory);

        var safeVersion = string.Concat(manifest.PackVersion.Select(ch => Path.GetInvalidFileNameChars().Contains(ch) ? '_' : ch));
        var destination = Path.Combine(_importArchiveDirectory, $"{safeVersion}.zip");
        if (File.Exists(destination))
            destination = Path.Combine(_importArchiveDirectory, $"{safeVersion}_{DateTime.UtcNow:yyyyMMdd_HHmmss}.zip");

        File.Copy(zipPath, destination, overwrite: false);
        return destination;
    }
}
