using System.IO;
using System.Net.Http;
using System.Security.Principal;
using System.ServiceProcess;
using Microsoft.Data.SqlClient;
using Microsoft.Win32;
using MEACSSupportTool.Models;

namespace MEACSSupportTool.Services;

public sealed class SupportEnvironmentService
{
    private const string DatabaseName = "magetegra";

    public async Task<SupportEnvironmentSnapshot> GetSnapshotAsync()
    {
        var machineName = Environment.MachineName;
        var currentUser = Environment.UserName;
        var isAdministrator = IsAdministrator();
        var hasInternetAccess = await CheckInternetAsync();
        var (rabbitInstalled, rabbitRunning) = GetRabbitMqStatus();
        var ssmsInstalled = IsSsmsInstalled();
        var sqlTarget = await FindLocalSqlTargetAsync();

        return new SupportEnvironmentSnapshot
        {
            MachineName = machineName,
            CurrentUser = currentUser,
            IsAdministrator = isAdministrator,
            HasInternetAccess = hasInternetAccess,
            RabbitMqInstalled = rabbitInstalled,
            RabbitMqRunning = rabbitRunning,
            SsmsInstalled = ssmsInstalled,
            SqlReachable = sqlTarget is not null,
            SqlDataSource = sqlTarget?.DataSource,
            MagEtegraDatabaseExists = sqlTarget?.DatabaseExists ?? false,
            SqlError = sqlTarget is null ? "Local SQL instance was not detected." : null
        };
    }

    public async Task<SqlTarget?> FindLocalSqlTargetAsync()
    {
        foreach (var candidate in GetSqlCandidates())
        {
            try
            {
                await using var connection = new SqlConnection(BuildConnectionString(candidate, "master"));
                await connection.OpenAsync();

                await using var command = connection.CreateCommand();
                command.CommandText = "SELECT CASE WHEN DB_ID(@database) IS NULL THEN 0 ELSE 1 END";
                command.Parameters.AddWithValue("@database", DatabaseName);

                var databaseExists = Convert.ToInt32(await command.ExecuteScalarAsync()) == 1;
                return new SqlTarget
                {
                    DataSource = candidate,
                    DatabaseExists = databaseExists
                };
            }
            catch
            {
                // Keep trying local instance candidates.
            }
        }

        return null;
    }

    public static string BuildConnectionString(string dataSource, string database) =>
        $"Data Source={dataSource};Initial Catalog={database};Integrated Security=True;TrustServerCertificate=True;Encrypt=False;Connect Timeout=3";

    public bool IsSsmsInstalled()
    {
        if (HasInstalledProduct(["SQL Server Management Studio", "Microsoft SQL Server Management Studio"]))
        {
            return true;
        }

        return GetSsmsExecutableCandidates().Any(File.Exists);
    }

    public Task<bool> HasInternetAccessAsync() => CheckInternetAsync();

    private static bool IsAdministrator()
    {
        using var identity = WindowsIdentity.GetCurrent();
        var principal = new WindowsPrincipal(identity);
        return principal.IsInRole(WindowsBuiltInRole.Administrator);
    }

    private static async Task<bool> CheckInternetAsync()
    {
        try
        {
            using var client = new HttpClient
            {
                Timeout = TimeSpan.FromSeconds(5)
            };

            using var request = new HttpRequestMessage(HttpMethod.Head, "https://github.com");
            using var response = await client.SendAsync(request);
            return response.IsSuccessStatusCode;
        }
        catch
        {
            return false;
        }
    }

    private static (bool installed, bool running) GetRabbitMqStatus()
    {
        try
        {
            using var service = ServiceController.GetServices()
                .FirstOrDefault(candidate => candidate.ServiceName.Equals("RabbitMQ", StringComparison.OrdinalIgnoreCase));

            if (service is null)
            {
                return (false, false);
            }

            return (true, service.Status == ServiceControllerStatus.Running);
        }
        catch
        {
            return (false, false);
        }
    }

    private static bool HasInstalledProduct(IEnumerable<string> knownDisplayNames)
    {
        foreach (var hive in new[] { RegistryHive.LocalMachine, RegistryHive.CurrentUser })
        {
            foreach (var view in new[] { RegistryView.Registry64, RegistryView.Registry32 })
            {
                const string uninstallKey = @"SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall";

                using var root = RegistryKey.OpenBaseKey(hive, view);
                using var uninstall = root.OpenSubKey(uninstallKey);
                if (uninstall is null)
                {
                    continue;
                }

                foreach (var subKeyName in uninstall.GetSubKeyNames())
                {
                    using var entry = uninstall.OpenSubKey(subKeyName);
                    var currentDisplayName = entry?.GetValue("DisplayName") as string;
                    if (string.IsNullOrWhiteSpace(currentDisplayName))
                    {
                        continue;
                    }

                    if (knownDisplayNames.Any(displayName =>
                        currentDisplayName.Equals(displayName, StringComparison.OrdinalIgnoreCase) ||
                        currentDisplayName.StartsWith(displayName + " ", StringComparison.OrdinalIgnoreCase) ||
                        currentDisplayName.StartsWith(displayName + " -", StringComparison.OrdinalIgnoreCase)))
                    {
                        return true;
                    }
                }
            }
        }

        return false;
    }

    private static IEnumerable<string> GetSsmsExecutableCandidates()
    {
        var roots = new[]
        {
            Environment.GetFolderPath(Environment.SpecialFolder.ProgramFiles),
            Environment.GetFolderPath(Environment.SpecialFolder.ProgramFilesX86)
        }
        .Where(path => !string.IsNullOrWhiteSpace(path))
        .Distinct(StringComparer.OrdinalIgnoreCase);

        foreach (var root in roots)
        {
            if (!Directory.Exists(root))
            {
                continue;
            }

            foreach (var directory in Directory.GetDirectories(root, "Microsoft SQL Server Management Studio*"))
            {
                yield return Path.Combine(directory, "Common7", "IDE", "Ssms.exe");
            }
        }
    }

    private static IEnumerable<string> GetSqlCandidates()
    {
        var candidates = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
        {
            ".",
            "localhost",
            Environment.MachineName,
            @".\SQLEXPRESS",
            $@"{Environment.MachineName}\SQLEXPRESS",
            @"localhost\SQLEXPRESS"
        };

        foreach (var instance in GetRegistrySqlInstances())
        {
            if (instance.Equals("MSSQLSERVER", StringComparison.OrdinalIgnoreCase))
            {
                continue;
            }

            candidates.Add($@".\{instance}");
            candidates.Add($@"{Environment.MachineName}\{instance}");
            candidates.Add($@"localhost\{instance}");
        }

        return candidates;
    }

    private static IEnumerable<string> GetRegistrySqlInstances()
    {
        const string keyPath = @"SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL";
        foreach (var view in new[] { RegistryView.Registry64, RegistryView.Registry32 })
        {
            using var root = RegistryKey.OpenBaseKey(RegistryHive.LocalMachine, view);
            using var key = root.OpenSubKey(keyPath);
            if (key is null)
            {
                continue;
            }

            foreach (var name in key.GetValueNames())
            {
                yield return name;
            }
        }
    }
}
