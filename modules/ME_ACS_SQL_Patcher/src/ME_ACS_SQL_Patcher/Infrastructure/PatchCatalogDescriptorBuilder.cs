using System.Security.Cryptography;
using System.Text;
using System.IO;
using MagDbPatcher.Models;
using MagDbPatcher.Services;

namespace MagDbPatcher.Infrastructure;

public sealed record PatchCatalogDescriptor(
    string DisplayVersion,
    string Label,
    string Summary,
    string Hash,
    int VersionCount,
    int PatchCount,
    int ScriptCount,
    DateTime? LastUpdatedUtc);

public static class PatchCatalogDescriptorBuilder
{
    private static readonly byte[] NewLineBytes = Encoding.UTF8.GetBytes("\n");

    public static PatchCatalogDescriptor FromVersionService(IVersionService versionService)
        => FromVersionData(
            versionService.GetPatchesFolder(),
            versionService.GetAllVersions(),
            versionService.GetAllPatches());

    public static PatchCatalogDescriptor FromVersionData(
        string patchesFolder,
        IReadOnlyCollection<VersionInfo> versions,
        IReadOnlyCollection<PatchInfo> patches)
    {
        var scriptCount = Directory.Exists(patchesFolder)
            ? Directory.GetFiles(patchesFolder, "*.sql", SearchOption.AllDirectories).Length
            : 0;

        var latestVersion = versions
            .OrderBy(v => v.Order)
            .ThenBy(v => v.Id, StringComparer.OrdinalIgnoreCase)
            .LastOrDefault()?.Id ?? "Unknown";

        var lastUpdatedUtc = GetLastUpdatedUtc(patchesFolder);
        var label = lastUpdatedUtc.HasValue
            ? $"{latestVersion} | {scriptCount} scripts | {lastUpdatedUtc.Value.AddHours(8):dd MMM yyyy HH:mm} MYT"
            : $"{latestVersion} | {scriptCount} scripts";

        var summary = $"{versions.Count} version(s), {patches.Count} patch link(s), {scriptCount} script(s)";

        return new PatchCatalogDescriptor(
            latestVersion,
            label,
            summary,
            ComputeFolderHash(patchesFolder),
            versions.Count,
            patches.Count,
            scriptCount,
            lastUpdatedUtc);
    }

    public static string ComputeFolderHash(string patchesFolder)
    {
        if (!Directory.Exists(patchesFolder))
            return string.Empty;

        var files = Directory.GetFiles(patchesFolder, "*", SearchOption.AllDirectories)
            .OrderBy(path => path, StringComparer.OrdinalIgnoreCase)
            .ToList();

        using var hash = IncrementalHash.CreateHash(HashAlgorithmName.SHA256);
        foreach (var file in files)
        {
            var relative = Path.GetRelativePath(patchesFolder, file)
                .Replace('\\', '/')
                .ToLowerInvariant();

            hash.AppendData(Encoding.UTF8.GetBytes(relative));
            hash.AppendData(NewLineBytes);

            using var stream = File.OpenRead(file);
            var buffer = new byte[81920];
            int read;
            while ((read = stream.Read(buffer, 0, buffer.Length)) > 0)
                hash.AppendData(buffer.AsSpan(0, read));

            hash.AppendData(NewLineBytes);
        }

        return Convert.ToHexString(hash.GetHashAndReset()).ToLowerInvariant();
    }

    private static DateTime? GetLastUpdatedUtc(string patchesFolder)
    {
        if (!Directory.Exists(patchesFolder))
            return null;

        var files = Directory.GetFiles(patchesFolder, "*", SearchOption.AllDirectories);
        if (files.Length == 0)
            return null;

        return files.Max(path => File.GetLastWriteTimeUtc(path));
    }
}
