using System.Globalization;
using System.IO;
using System.Net.Http;
using System.Security.Cryptography;
using System.Text.Json;
using MagDbPatcher.Infrastructure;

namespace MagDbPatcher.Services;

public enum AppUpdateStatus
{
    NotConfigured,
    NoUpdateAvailable,
    UpdateAvailable
}

public sealed record AppUpdateCheckResult(
    AppUpdateStatus Status,
    string Message,
    string? InstallerUrl = null,
    string? InstallerSha256 = null,
    string? ReleaseNotes = null,
    string? ServerPatchCatalogLabel = null,
    string? ServerPatchCatalogHash = null)
{
    public bool IsUpdateAvailable => Status == AppUpdateStatus.UpdateAvailable;
}

public sealed class BuildDateUpdateService
{
    private static readonly HttpClient Http = new() { Timeout = TimeSpan.FromSeconds(15) };

    public async Task<AppUpdateCheckResult> CheckForUpdatesAsync(string? feedPath, CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(feedPath))
        {
            return new AppUpdateCheckResult(AppUpdateStatus.NotConfigured, "Set an update feed path first.");
        }

        string latestJson;
        string installerLocation;

        try
        {
            if (PatcherUpdateFeedResolver.TryGetLocalDirectory(feedPath, out var localDirectory))
            {
                var latestPath = Path.Combine(localDirectory, "latest.json");
                if (!File.Exists(latestPath))
                {
                    throw new InvalidOperationException($"Could not find latest.json in {localDirectory}.");
                }

                latestJson = await File.ReadAllTextAsync(latestPath, cancellationToken);
                installerLocation = localDirectory;
            }
            else
            {
                var latestUrl = PatcherUpdateFeedResolver.BuildLatestJsonUrl(feedPath);
                latestJson = await Http.GetStringAsync(latestUrl, cancellationToken);
                installerLocation = feedPath.TrimEnd('/');
            }
        }
        catch (Exception ex)
        {
            throw new InvalidOperationException($"Could not load update feed '{feedPath}': {ex.Message}", ex);
        }

        using var document = JsonDocument.Parse(latestJson);
        var root = document.RootElement;

        var installerName = GetOptionalString(root, "installerName") ?? "ME_ACS_SQL_Patcher-win-Setup.exe";
        var installerSha256 = GetOptionalString(root, "installerSha256");
        var releaseNotes = NormalizeMultiline(GetOptionalString(root, "releaseNotes"));
        var serverPatchCatalogLabel = GetOptionalString(root, "patchCatalogLabel");
        var serverPatchCatalogHash = GetOptionalString(root, "patchCatalogHash");
        var serverBuildDate = GetRequiredBuildDate(root);

        var localBuildDate = AppMetadata.BuildDate;
        var newerBuildAvailable = serverBuildDate > localBuildDate;
        var patchCatalogRefreshAvailable = ShouldRefreshPatchCatalog(serverPatchCatalogHash);

        if (!newerBuildAvailable && !patchCatalogRefreshAvailable)
        {
            return new AppUpdateCheckResult(AppUpdateStatus.NoUpdateAvailable, BuildUpToDateMessage(localBuildDate));
        }

        string installerUrl;
        if (PatcherUpdateFeedResolver.TryGetLocalDirectory(feedPath, out var installerDirectory))
        {
            installerUrl = PatcherUpdateFeedResolver.BuildLocalInstallerPath(installerDirectory, installerName);
            if (!File.Exists(installerUrl))
            {
                throw new InvalidOperationException($"Update installer was not found: {installerUrl}");
            }

            VerifyInstallerHashIfPresent(installerUrl, installerSha256);
        }
        else
        {
            installerUrl = $"{installerLocation}/{installerName}";
        }

        return new AppUpdateCheckResult(
            AppUpdateStatus.UpdateAvailable,
            BuildUpdatePrompt(localBuildDate, serverBuildDate, releaseNotes, serverPatchCatalogLabel, patchCatalogRefreshAvailable),
            installerUrl,
            installerSha256,
            releaseNotes,
            serverPatchCatalogLabel,
            serverPatchCatalogHash);
    }

    private static DateTime GetRequiredBuildDate(JsonElement root)
    {
        if (!root.TryGetProperty("buildDate", out var buildDateElement) ||
            !DateTime.TryParse(buildDateElement.GetString(), null, DateTimeStyles.RoundtripKind, out var serverBuildDate))
        {
            throw new InvalidOperationException("latest.json is missing or has an invalid 'buildDate' field.");
        }

        return serverBuildDate;
    }

    private static string? GetOptionalString(JsonElement root, string propertyName)
        => root.TryGetProperty(propertyName, out var property) ? property.GetString() : null;

    private static bool ShouldRefreshPatchCatalog(string? serverPatchCatalogHash)
    {
        if (string.IsNullOrWhiteSpace(serverPatchCatalogHash))
        {
            return false;
        }

        var localPatchCatalogHash = AppMetadata.InstalledPatchCatalogHash;
        return !string.Equals(
            serverPatchCatalogHash.Trim(),
            localPatchCatalogHash?.Trim(),
            StringComparison.OrdinalIgnoreCase);
    }

    private static void VerifyInstallerHashIfPresent(string installerPath, string? expectedSha256)
    {
        if (string.IsNullOrWhiteSpace(expectedSha256))
        {
            return;
        }

        using var stream = File.OpenRead(installerPath);
        var actualHash = Convert.ToHexString(SHA256.HashData(stream)).ToLowerInvariant();
        if (!string.Equals(actualHash, expectedSha256.Trim(), StringComparison.OrdinalIgnoreCase))
        {
            throw new InvalidOperationException(
                $"Downloaded installer failed integrity verification. Expected SHA-256 {expectedSha256}, got {actualHash}.");
        }
    }

    private static string BuildUpToDateMessage(DateTime buildDate)
        => buildDate == DateTime.MinValue
            ? "Patcher is up to date."
            : $"Patcher is up to date (built {buildDate.AddHours(8):yyyy-MM-dd HH:mm} MYT).";

    private static string BuildUpdatePrompt(
        DateTime currentBuildDate,
        DateTime serverBuildDate,
        string? releaseNotes,
        string? serverPatchCatalogLabel,
        bool patchCatalogRefreshAvailable)
    {
        var lines = new List<string>();

        if (serverBuildDate > currentBuildDate)
        {
            lines.Add("A newer ME_ACS SQL Patcher build is available.");
            lines.Add(string.Empty);
            lines.Add($"Current build: {FormatBuildDate(currentBuildDate)}");
            lines.Add($"Incoming build: {FormatBuildDate(serverBuildDate)}");
        }
        else
        {
            lines.Add("A refreshed ME_ACS SQL Patcher package is available.");
        }

        if (patchCatalogRefreshAvailable && !string.IsNullOrWhiteSpace(serverPatchCatalogLabel))
        {
            lines.Add(string.Empty);
            lines.Add($"Bundled patch catalog: {serverPatchCatalogLabel}");
        }

        if (!string.IsNullOrWhiteSpace(releaseNotes))
        {
            lines.Add(string.Empty);
            lines.Add("Notes:");
            lines.Add(releaseNotes);
        }

        return string.Join(Environment.NewLine, lines);
    }

    private static string FormatBuildDate(DateTime buildDate)
        => buildDate == DateTime.MinValue
            ? "Unknown"
            : $"{buildDate.AddHours(8):dd MMM yyyy HH:mm} MYT";

    private static string? NormalizeMultiline(string? value)
    {
        if (string.IsNullOrWhiteSpace(value))
        {
            return null;
        }

        return value
            .Replace("\r\n", "\n", StringComparison.Ordinal)
            .Replace('\r', '\n')
            .Trim();
    }
}

internal static class PatcherUpdateFeedResolver
{
    public static bool TryGetLocalDirectory(string? feedPath, out string directoryPath)
    {
        directoryPath = string.Empty;
        if (string.IsNullOrWhiteSpace(feedPath))
        {
            return false;
        }

        var trimmed = feedPath.Trim();
        if (Uri.TryCreate(trimmed, UriKind.Absolute, out var uri))
        {
            if (!uri.IsFile)
            {
                return false;
            }

            directoryPath = Path.GetFullPath(uri.LocalPath);
            return true;
        }

        if (!Path.IsPathRooted(trimmed))
        {
            return false;
        }

        directoryPath = Path.GetFullPath(trimmed);
        return true;
    }

    public static string BuildLatestJsonUrl(string feedPath)
        => $"{feedPath.TrimEnd('/')}/latest.json";

    public static string BuildLocalInstallerPath(string directoryPath, string installerName)
    {
        var root = EnsureTrailingSeparator(Path.GetFullPath(directoryPath));
        var combined = Path.GetFullPath(Path.Combine(directoryPath, installerName));
        if (!combined.StartsWith(root, StringComparison.OrdinalIgnoreCase))
        {
            throw new InvalidOperationException($"Installer path escapes update feed folder: {installerName}");
        }

        return combined;
    }

    private static string EnsureTrailingSeparator(string path)
        => path.EndsWith(Path.DirectorySeparatorChar) ? path : path + Path.DirectorySeparatorChar;
}
