using System.Globalization;
using System.IO;
using System.Net.Http;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using MEACSSupportTool.Infrastructure;

namespace MEACSSupportTool.Services;

public interface ISupportToolUpdateService
{
    Task<SupportToolUpdateCheckResult> CheckForUpdatesAsync(string? feedPath, CancellationToken cancellationToken = default);
    Task ApplyPendingUpdateAndRestartAsync(string installerUrl, string? installerSha256 = null, CancellationToken cancellationToken = default);
}

public enum SupportToolUpdateStatus
{
    NotConfigured,
    NoUpdateAvailable,
    UpdateAvailable
}

public sealed record SupportToolUpdateCheckResult(
    SupportToolUpdateStatus Status,
    string Message,
    string? InstallerUrl = null,
    string? InstallerSha256 = null,
    string? ReleaseNotes = null)
{
    public bool CanApplyNow => InstallerUrl != null;
    public bool IsUpdateAvailable => Status == SupportToolUpdateStatus.UpdateAvailable;
}

public sealed class SupportToolUpdateService : ISupportToolUpdateService
{
    private static readonly HttpClient Http = new() { Timeout = TimeSpan.FromSeconds(15) };

    public async Task<SupportToolUpdateCheckResult> CheckForUpdatesAsync(string? feedPath, CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(feedPath))
        {
            return new SupportToolUpdateCheckResult(SupportToolUpdateStatus.NotConfigured, "Set an app update feed path first.");
        }

        string json;
        string installerLocation;
        string? installerSha256 = null;
        string? releaseNotes = null;

        try
        {
            if (SupportToolUpdateFeedResolver.TryGetLocalDirectory(feedPath, out var localDirectory))
            {
                var latestPath = Path.Combine(localDirectory, "latest.json");
                if (!File.Exists(latestPath))
                {
                    throw new InvalidOperationException($"Could not find latest.json in {localDirectory}.");
                }

                json = await File.ReadAllTextAsync(latestPath, cancellationToken);
                installerLocation = localDirectory;
            }
            else
            {
                var latestUrl = SupportToolUpdateFeedResolver.BuildLatestJsonUrl(feedPath);
                json = await Http.GetStringAsync(latestUrl, cancellationToken);
                installerLocation = feedPath.TrimEnd('/');
            }
        }
        catch (Exception ex)
        {
            throw new InvalidOperationException($"Could not load update feed '{feedPath}': {ex.Message}", ex);
        }

        using var document = JsonDocument.Parse(json);
        var root = document.RootElement;

        if (root.TryGetProperty("installerSha256", out var installerSha256Element))
        {
            installerSha256 = installerSha256Element.GetString();
        }

        if (root.TryGetProperty("releaseNotes", out var releaseNotesElement))
        {
            releaseNotes = NormalizeReleaseNotes(releaseNotesElement.GetString());
        }

        if (!root.TryGetProperty("buildDate", out var buildDateElement) ||
            !DateTime.TryParse(buildDateElement.GetString(), null, DateTimeStyles.RoundtripKind, out var serverDate))
        {
            throw new InvalidOperationException("latest.json is missing or has an invalid 'buildDate' field.");
        }

        var appDate = SupportToolMetadata.BuildDate;
        if (serverDate <= appDate)
        {
            return new SupportToolUpdateCheckResult(
                SupportToolUpdateStatus.NoUpdateAvailable,
                BuildUpToDateMessage(appDate));
        }

        var installerName = root.TryGetProperty("installerName", out var installerNameElement)
            ? installerNameElement.GetString() ?? "MEACSSupportTool-win-Setup.exe"
            : "MEACSSupportTool-win-Setup.exe";

        string installerPath;
        if (SupportToolUpdateFeedResolver.TryGetLocalDirectory(feedPath, out var installerDirectory))
        {
            installerPath = SupportToolUpdateFeedResolver.BuildLocalInstallerPath(installerDirectory, installerName);
            if (!File.Exists(installerPath))
            {
                throw new InvalidOperationException($"Update installer was not found: {installerPath}");
            }

            VerifyInstallerHashIfPresent(installerPath, installerSha256);
        }
        else
        {
            installerPath = $"{installerLocation}/{installerName}";
        }

        return new SupportToolUpdateCheckResult(
            SupportToolUpdateStatus.UpdateAvailable,
            BuildUpdatePrompt(appDate, serverDate, releaseNotes),
            installerPath,
            installerSha256,
            releaseNotes);
    }

    public async Task ApplyPendingUpdateAndRestartAsync(string installerUrl, string? installerSha256 = null, CancellationToken cancellationToken = default)
    {
        if (SupportToolUpdateFeedResolver.TryGetLocalFile(installerUrl, out var localInstaller))
        {
            VerifyInstallerHashIfPresent(localInstaller, installerSha256);
            LaunchInstaller(localInstaller);
            System.Windows.Application.Current.Shutdown();
            return;
        }

        var tempDir = Path.Combine(Path.GetTempPath(), "MEACSSupportTool-update");
        Directory.CreateDirectory(tempDir);
        var localPath = Path.Combine(tempDir, $"Setup-{Guid.NewGuid():N}.exe");

        using var response = await Http.GetAsync(installerUrl, HttpCompletionOption.ResponseHeadersRead, cancellationToken);
        response.EnsureSuccessStatusCode();

        await using (var fileStream = File.Create(localPath))
        {
            await response.Content.CopyToAsync(fileStream, cancellationToken);
        }

        VerifyInstallerHashIfPresent(localPath, installerSha256);
        LaunchInstaller(localPath);
        System.Windows.Application.Current.Shutdown();
    }

    private static void LaunchInstaller(string installerPath)
    {
        System.Diagnostics.Process.Start(new System.Diagnostics.ProcessStartInfo
        {
            FileName = installerPath,
            UseShellExecute = true
        });
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

    private static string BuildUpToDateMessage(DateTime appDate)
    {
        var builder = new StringBuilder();
        builder.Append($"Toolkit is up to date (built {appDate.AddHours(8):yyyy-MM-dd HH:mm} MYT).");
        return builder.ToString();
    }

    private static string BuildUpdatePrompt(DateTime currentBuildDate, DateTime serverBuildDate, string? releaseNotes)
    {
        var lines = new List<string>
        {
            "A newer ME ACS Support Tool build is available.",
            string.Empty,
            $"Current build: {currentBuildDate.AddHours(8):dd MMM yyyy HH:mm} MYT",
            $"Incoming build: {serverBuildDate.AddHours(8):dd MMM yyyy HH:mm} MYT"
        };

        if (!string.IsNullOrWhiteSpace(releaseNotes))
        {
            lines.Add(string.Empty);
            lines.Add("Notes:");
            lines.Add(releaseNotes);
        }

        lines.Add(string.Empty);
        lines.Add("Download and install now?");
        return string.Join(Environment.NewLine, lines);
    }

    private static string? NormalizeReleaseNotes(string? releaseNotes)
    {
        if (string.IsNullOrWhiteSpace(releaseNotes))
        {
            return null;
        }

        return releaseNotes
            .Replace("\r\n", "\n", StringComparison.Ordinal)
            .Replace('\r', '\n')
            .Trim();
    }
}

internal static class SupportToolUpdateFeedResolver
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
            if (uri.IsFile)
            {
                directoryPath = Path.GetFullPath(uri.LocalPath);
                return true;
            }

            return false;
        }

        if (!Path.IsPathRooted(trimmed))
        {
            return false;
        }

        directoryPath = Path.GetFullPath(trimmed);
        return true;
    }

    public static bool TryGetLocalFile(string? pathOrUrl, out string filePath)
    {
        filePath = string.Empty;
        if (string.IsNullOrWhiteSpace(pathOrUrl))
        {
            return false;
        }

        var trimmed = pathOrUrl.Trim();
        if (Uri.TryCreate(trimmed, UriKind.Absolute, out var uri))
        {
            if (!uri.IsFile)
            {
                return false;
            }

            filePath = Path.GetFullPath(uri.LocalPath);
            return true;
        }

        if (!Path.IsPathRooted(trimmed))
        {
            return false;
        }

        filePath = Path.GetFullPath(trimmed);
        return true;
    }

    public static string BuildLatestJsonUrl(string feedPath) => $"{feedPath.TrimEnd('/')}/latest.json";

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
