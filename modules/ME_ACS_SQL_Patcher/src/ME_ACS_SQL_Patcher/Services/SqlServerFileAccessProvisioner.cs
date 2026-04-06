using System.IO;
using System.Security.AccessControl;
using System.Security.Principal;

namespace MagDbPatcher.Services;

public static class SqlServerFileAccessProvisioner
{
    private static readonly FileSystemRights TempWorkspaceRights =
        FileSystemRights.Modify |
        FileSystemRights.Synchronize;

    public static void EnsureSqlServiceAccess(string serverName, string folderPath)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(serverName);
        ArgumentException.ThrowIfNullOrWhiteSpace(folderPath);

        var directory = Directory.CreateDirectory(folderPath);
        var security = directory.GetAccessControl();
        var modified = false;

        foreach (var identity in BuildCandidateIdentities(serverName))
        {
            if (!TryBuildRule(identity, out var rule))
                continue;

            if (HasEquivalentRule(security, identity))
                continue;

            security.AddAccessRule(rule);
            modified = true;
        }

        if (modified)
            directory.SetAccessControl(security);
    }

    internal static IReadOnlyList<string> BuildCandidateIdentities(string serverName)
    {
        var identities = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
        {
            @"NT AUTHORITY\SYSTEM",
            @"NT AUTHORITY\NETWORK SERVICE",
            @"NT AUTHORITY\LOCAL SERVICE"
        };

        var instanceName = ExtractInstanceName(serverName);
        if (!string.IsNullOrWhiteSpace(instanceName))
        {
            if (string.Equals(instanceName, "MSSQLSERVER", StringComparison.OrdinalIgnoreCase))
                identities.Add(@"NT SERVICE\MSSQLSERVER");
            else
                identities.Add($@"NT SERVICE\MSSQL${instanceName}");
        }

        return identities.ToList();
    }

    private static string? ExtractInstanceName(string serverName)
    {
        var trimmed = serverName.Trim();
        if (string.IsNullOrWhiteSpace(trimmed))
            return null;

        var slashIndex = trimmed.LastIndexOf('\\');
        if (slashIndex < 0 || slashIndex == trimmed.Length - 1)
            return "MSSQLSERVER";

        var instance = trimmed[(slashIndex + 1)..].Trim();
        if (instance.StartsWith("MSSQLLocalDB", StringComparison.OrdinalIgnoreCase) ||
            trimmed.StartsWith("(localdb)", StringComparison.OrdinalIgnoreCase))
        {
            return null;
        }

        return instance;
    }

    private static bool TryBuildRule(string identity, out FileSystemAccessRule rule)
    {
        rule = null!;

        try
        {
            var account = new NTAccount(identity);
            _ = (SecurityIdentifier)account.Translate(typeof(SecurityIdentifier));
            rule = new FileSystemAccessRule(
                account,
                TempWorkspaceRights,
                InheritanceFlags.ContainerInherit | InheritanceFlags.ObjectInherit,
                PropagationFlags.None,
                AccessControlType.Allow);
            return true;
        }
        catch
        {
            return false;
        }
    }

    private static bool HasEquivalentRule(DirectorySecurity security, string identity)
    {
        foreach (FileSystemAccessRule existing in security.GetAccessRules(true, true, typeof(NTAccount)))
        {
            if (!string.Equals(existing.IdentityReference.Value, identity, StringComparison.OrdinalIgnoreCase))
                continue;

            if (existing.AccessControlType != AccessControlType.Allow)
                continue;

            if ((existing.FileSystemRights & TempWorkspaceRights) == TempWorkspaceRights)
                return true;
        }

        return false;
    }
}
