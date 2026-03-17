using System.Diagnostics;
using System.IO;
using System.Net.Http;
using System.Security.Principal;
using System.ServiceProcess;
using System.Text.RegularExpressions;
using Microsoft.Data.SqlClient;
using Microsoft.Win32;
using MEACSSupportTool.Models;

namespace MEACSSupportTool.Services;

public sealed class SupportActionRunner
{
    private const string SsmsInstallerUrl = "https://aka.ms/ssmsfullsetup";
    private readonly SupportEnvironmentService _environmentService;
    private readonly string _sqlScriptPath;

    public SupportActionRunner(SupportEnvironmentService environmentService, string sqlScriptPath)
    {
        _environmentService = environmentService;
        _sqlScriptPath = sqlScriptPath;
    }

    public async Task<RunResult> RunRabbitMqRepairAsync(RunLogSession log)
    {
        await log.WriteAsync("Starting RabbitMQ repair.");

        if (!IsAdministrator())
        {
            await log.WriteAsync("Blocked because the app is not running as Administrator.");
            return new RunResult
            {
                Outcome = RunOutcome.Failed,
                Summary = "Run the tool as Administrator before using RabbitMQ Repair."
            };
        }

        var rabbitVersion = DetectRabbitMqVersion();
        var erlangVersion = DetectErlangVersion();

        if (string.IsNullOrWhiteSpace(rabbitVersion) || string.IsNullOrWhiteSpace(erlangVersion))
        {
            await log.WriteAsync($"Version detection failed. RabbitMQ={rabbitVersion ?? "unknown"}, Erlang={erlangVersion ?? "unknown"}.");
            return new RunResult
            {
                Outcome = RunOutcome.Failed,
                Summary = "Could not auto-detect RabbitMQ and Erlang versions on this PC."
            };
        }

        await log.WriteAsync($"Detected RabbitMQ {rabbitVersion} and Erlang OTP {erlangVersion}.");

        var erlangUrl = $"https://github.com/erlang/otp/releases/download/OTP-{erlangVersion}/otp_win64_{erlangVersion}.exe";
        var rabbitUrl = $"https://github.com/rabbitmq/rabbitmq-server/releases/download/v{rabbitVersion}/rabbitmq-server-{rabbitVersion}.exe";
        var erlangInstaller = Path.Combine(Path.GetTempPath(), $"otp_{erlangVersion}_{Guid.NewGuid():N}.exe");
        var rabbitInstaller = Path.Combine(Path.GetTempPath(), $"rabbitmq_{rabbitVersion}_{Guid.NewGuid():N}.exe");

        try
        {
            if (!await _environmentService.HasInternetAccessAsync())
            {
                await log.WriteAsync("RabbitMQ repair requires internet access to download replacement installers.");
                return new RunResult
                {
                    Outcome = RunOutcome.Failed,
                    Summary = "Internet access is required before RabbitMQ Repair can continue."
                };
            }

            await DownloadFileAsync(erlangUrl, erlangInstaller, log, "Erlang OTP");
            await DownloadFileAsync(rabbitUrl, rabbitInstaller, log, "RabbitMQ");
            await log.WriteAsync("Replacement installers downloaded successfully. Continuing with uninstall and reinstall.");

            await StopProcessesAsync(log, ["MagServer", "erl", "epmd"]);
            await StopRabbitMqServiceAsync(log);
            await UninstallRabbitMqAsync(log);
            await UninstallErlangAsync(log);
            await CleanupRabbitMqFoldersAsync(log);

            await log.WriteAsync("Installing Erlang OTP silently.");
            await ExecuteProcessAsync(erlangInstaller, "/S", log);
            await Task.Delay(TimeSpan.FromSeconds(8));

            await log.WriteAsync("Installing RabbitMQ silently.");
            await ExecuteProcessAsync(rabbitInstaller, "/S", log);
            await Task.Delay(TimeSpan.FromSeconds(12));

            await ConfigureRabbitMqNodeNameAsync(log);
            await StartRabbitMqServiceAsync(log);

            if (!await IsRabbitMqRunningAsync())
            {
                await log.WriteAsync("RabbitMQ service did not reach the Running state.");
                return new RunResult
                {
                    Outcome = RunOutcome.Failed,
                    Summary = "RabbitMQ reinstall finished, but the service did not start successfully."
                };
            }

            await log.WriteAsync("RabbitMQ repair completed successfully.");
            return new RunResult
            {
                Outcome = RunOutcome.Success,
                Summary = "RabbitMQ and Erlang were reinstalled. Restart MagServer as Administrator."
            };
        }
        catch (HttpRequestException ex)
        {
            await log.WriteAsync($"Failed to download replacement installers: {ex.Message}");
            return new RunResult
            {
                Outcome = RunOutcome.Failed,
                Summary = "Could not download RabbitMQ or Erlang installers. The existing installation was left unchanged."
            };
        }
        finally
        {
            SafeDelete(erlangInstaller);
            SafeDelete(rabbitInstaller);
        }
    }

    public async Task<RunResult> RunSolveClientLagAsync(RunLogSession log)
    {
        await log.WriteAsync("Starting SQL optimization for Solve Client Lag.");

        var sqlTarget = await _environmentService.FindLocalSqlTargetAsync();
        if (sqlTarget is null)
        {
            await log.WriteAsync("No reachable local SQL instance was detected.");
            return new RunResult
            {
                Outcome = RunOutcome.Failed,
                Summary = "Local SQL Server was not found."
            };
        }

        await log.WriteAsync($"Using SQL Server data source: {sqlTarget.DataSource}");

        if (!sqlTarget.DatabaseExists)
        {
            await log.WriteAsync("Database magetegra was not found.");
            return new RunResult
            {
                Outcome = RunOutcome.Failed,
                Summary = "Database 'magetegra' does not exist on the detected local SQL instance."
            };
        }

        await using var connection = new SqlConnection(SupportEnvironmentService.BuildConnectionString(sqlTarget.DataSource, "magetegra"));
        await connection.OpenAsync();

        await using (var tableCommand = connection.CreateCommand())
        {
            tableCommand.CommandText = """
                SELECT CASE
                    WHEN OBJECT_ID(N'dbo.events', N'U') IS NULL THEN 0
                    ELSE 1
                END
                """;

            var tableExists = Convert.ToInt32(await tableCommand.ExecuteScalarAsync()) == 1;
            if (!tableExists)
            {
                await log.WriteAsync("Table dbo.events was not found.");
                return new RunResult
                {
                    Outcome = RunOutcome.Failed,
                    Summary = "Table 'dbo.events' does not exist in the magetegra database."
                };
            }
        }

        await using (var indexCommand = connection.CreateCommand())
        {
            indexCommand.CommandText = """
                SELECT CASE
                    WHEN EXISTS (
                        SELECT 1
                        FROM sys.indexes
                        WHERE name = N'IX_events'
                        AND object_id = OBJECT_ID(N'dbo.events')
                    ) THEN 1
                    ELSE 0
                END
                """;

            var indexExists = Convert.ToInt32(await indexCommand.ExecuteScalarAsync()) == 1;
            if (indexExists)
            {
                await log.WriteAsync("Index IX_events already exists. No SQL changes were needed.");
                return new RunResult
                {
                    Outcome = RunOutcome.AlreadyApplied,
                    Summary = "The lag-fix index already exists. No change was made."
                };
            }
        }

        if (!File.Exists(_sqlScriptPath))
        {
            await log.WriteAsync($"SQL file not found: {_sqlScriptPath}");
            return new RunResult
            {
                Outcome = RunOutcome.Failed,
                Summary = "The bundled SQL script is missing from the tool output."
            };
        }

        var sqlScript = await File.ReadAllTextAsync(_sqlScriptPath);
        var batches = Regex.Split(sqlScript, @"^\s*GO\s*$", RegexOptions.Multiline | RegexOptions.IgnoreCase)
            .Where(batch => !string.IsNullOrWhiteSpace(batch))
            .ToList();

        foreach (var batch in batches)
        {
            await using var batchCommand = connection.CreateCommand();
            batchCommand.CommandText = batch;
            batchCommand.CommandTimeout = 120;
            await batchCommand.ExecuteNonQueryAsync();
        }

        await log.WriteAsync("SQL optimization completed successfully.");
        return new RunResult
        {
            Outcome = RunOutcome.Success,
            Summary = "The lag-fix index was created successfully on magetegra.dbo.events."
        };
    }

    public async Task<RunResult> RunInstallSsmsAsync(RunLogSession log)
    {
        await log.WriteAsync("Starting Install SSMS.");

        if (_environmentService.IsSsmsInstalled())
        {
            await log.WriteAsync("SQL Server Management Studio is already installed on this PC.");
            return new RunResult
            {
                Outcome = RunOutcome.AlreadyApplied,
                Summary = "SQL Server Management Studio is already installed on this PC."
            };
        }

        var installerPath = Path.Combine(Path.GetTempPath(), $"ssms-setup-{Guid.NewGuid():N}.exe");
        try
        {
            if (!await _environmentService.HasInternetAccessAsync())
            {
                await log.WriteAsync("Install SSMS requires internet access to download the installer.");
                return new RunResult
                {
                    Outcome = RunOutcome.Failed,
                    Summary = "Internet access is required before Install SSMS can continue."
                };
            }

            await DownloadFileAsync(SsmsInstallerUrl, installerPath, log, "SQL Server Management Studio");
            var exitCode = await LaunchInstallerAsync(installerPath, log);

            await Task.Delay(TimeSpan.FromSeconds(2));
            var installed = _environmentService.IsSsmsInstalled();
            if (installed)
            {
                await log.WriteAsync("SQL Server Management Studio was detected after setup.");
                return new RunResult
                {
                    Outcome = RunOutcome.Success,
                    Summary = "SQL Server Management Studio was installed successfully."
                };
            }

            await log.WriteAsync($"Installer exited with code {exitCode}, but SSMS was not detected.");
            return new RunResult
            {
                Outcome = RunOutcome.Failed,
                Summary = "SSMS setup closed, but SQL Server Management Studio was not detected afterward."
            };
        }
        catch (HttpRequestException ex)
        {
            await log.WriteAsync($"Failed to download the SSMS installer: {ex.Message}");
            return new RunResult
            {
                Outcome = RunOutcome.Failed,
                Summary = "Could not download the SSMS installer from Microsoft."
            };
        }
        finally
        {
            SafeDelete(installerPath);
        }
    }

    private static bool IsAdministrator()
    {
        using var identity = WindowsIdentity.GetCurrent();
        var principal = new WindowsPrincipal(identity);
        return principal.IsInRole(WindowsBuiltInRole.Administrator);
    }

    private static string? DetectRabbitMqVersion()
    {
        var version = FindDisplayVersion("RabbitMQ Server");
        if (!string.IsNullOrWhiteSpace(version))
        {
            return version;
        }

        var programFiles = Environment.GetFolderPath(Environment.SpecialFolder.ProgramFiles);
        var rabbitRoot = Path.Combine(programFiles, "RabbitMQ Server");
        if (!Directory.Exists(rabbitRoot))
        {
            return null;
        }

        return Directory.GetDirectories(rabbitRoot, "rabbitmq_server-*")
            .Select(Path.GetFileName)
            .Where(name => !string.IsNullOrWhiteSpace(name))
            .Select(name => name!.Replace("rabbitmq_server-", string.Empty))
            .FirstOrDefault();
    }

    private static string? DetectErlangVersion()
    {
        var version = FindDisplayVersion("Erlang OTP");
        if (!string.IsNullOrWhiteSpace(version))
        {
            return version;
        }

        var programFiles = Environment.GetFolderPath(Environment.SpecialFolder.ProgramFiles);
        if (!Directory.Exists(programFiles))
        {
            return null;
        }

        return Directory.GetDirectories(programFiles, "erl*")
            .Select(Path.GetFileName)
            .Where(name => !string.IsNullOrWhiteSpace(name))
            .Select(name => name!.Replace("erl", string.Empty))
            .FirstOrDefault();
    }

    private static string? FindDisplayVersion(string displayName)
    {
        const string uninstallKey = @"SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall";
        foreach (var view in new[] { RegistryView.Registry64, RegistryView.Registry32 })
        {
            using var root = RegistryKey.OpenBaseKey(RegistryHive.LocalMachine, view);
            using var uninstall = root.OpenSubKey(uninstallKey);
            if (uninstall is null)
            {
                continue;
            }

            foreach (var subKeyName in uninstall.GetSubKeyNames())
            {
                using var entry = uninstall.OpenSubKey(subKeyName);
                var currentDisplayName = entry?.GetValue("DisplayName") as string;
                if (string.IsNullOrWhiteSpace(currentDisplayName) ||
                    currentDisplayName.IndexOf(displayName, StringComparison.OrdinalIgnoreCase) < 0)
                {
                    continue;
                }

                var version = entry?.GetValue("DisplayVersion") as string;
                if (!string.IsNullOrWhiteSpace(version))
                {
                    return version;
                }
            }
        }

        return null;
    }

    private static async Task StopProcessesAsync(RunLogSession log, IEnumerable<string> processNames)
    {
        foreach (var processName in processNames)
        {
            var processes = Process.GetProcessesByName(processName);
            if (processes.Length == 0)
            {
                await log.WriteAsync($"Process {processName}.exe is not running.");
                continue;
            }

            foreach (var process in processes)
            {
                try
                {
                    process.Kill(entireProcessTree: true);
                    await log.WriteAsync($"Stopped process {process.ProcessName}.exe (PID {process.Id}).");
                }
                catch (Exception ex)
                {
                    await log.WriteAsync($"Failed to stop {process.ProcessName}.exe: {ex.Message}");
                }
            }
        }
    }

    private static async Task StopRabbitMqServiceAsync(RunLogSession log)
    {
        try
        {
            using var service = new ServiceController("RabbitMQ");
            if (service.Status == ServiceControllerStatus.Stopped)
            {
                await log.WriteAsync("RabbitMQ service is already stopped.");
                return;
            }

            await log.WriteAsync("Stopping RabbitMQ service.");
            service.Stop();
            service.WaitForStatus(ServiceControllerStatus.Stopped, TimeSpan.FromSeconds(20));
        }
        catch (InvalidOperationException)
        {
            await log.WriteAsync("RabbitMQ service is not installed.");
        }
    }

    private static async Task UninstallRabbitMqAsync(RunLogSession log)
    {
        var programFiles = Environment.GetFolderPath(Environment.SpecialFolder.ProgramFiles);
        var uninstallPath = Path.Combine(programFiles, "RabbitMQ Server", "uninstall.exe");
        if (!File.Exists(uninstallPath))
        {
            await log.WriteAsync("RabbitMQ uninstaller was not found. Continuing with cleanup.");
            return;
        }

        await log.WriteAsync("Running RabbitMQ uninstaller.");
        await ExecuteProcessAsync(uninstallPath, "/S", log);
    }

    private static async Task UninstallErlangAsync(RunLogSession log)
    {
        var uninstallers = new List<string>();
        var programFiles = Environment.GetFolderPath(Environment.SpecialFolder.ProgramFiles);
        var canonical = Path.Combine(programFiles, "Erlang OTP", "Uninstall.exe");
        if (File.Exists(canonical))
        {
            uninstallers.Add(canonical);
        }

        if (Directory.Exists(programFiles))
        {
            uninstallers.AddRange(Directory.GetDirectories(programFiles, "erl*")
                .Select(path => Path.Combine(path, "Uninstall.exe"))
                .Where(File.Exists));
        }

        if (uninstallers.Count == 0)
        {
            await log.WriteAsync("Erlang uninstaller was not found. Continuing with cleanup.");
            return;
        }

        foreach (var uninstaller in uninstallers.Distinct(StringComparer.OrdinalIgnoreCase))
        {
            await log.WriteAsync($"Running Erlang uninstaller: {uninstaller}");
            await ExecuteProcessAsync(uninstaller, "/S", log);
        }
    }

    private static async Task CleanupRabbitMqFoldersAsync(RunLogSession log)
    {
        var cleanupTargets = new[]
        {
            Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), "RabbitMQ"),
            Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ProgramFiles), "RabbitMQ Server"),
            Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ProgramFiles), "Erlang OTP"),
            @"C:\Windows\System32\config\systemprofile\AppData\Roaming\RabbitMQ"
        }.ToList();

        var programFiles = Environment.GetFolderPath(Environment.SpecialFolder.ProgramFiles);
        if (Directory.Exists(programFiles))
        {
            cleanupTargets.AddRange(Directory.GetDirectories(programFiles, "erl*"));
        }

        var x86ProgramFiles = Environment.GetFolderPath(Environment.SpecialFolder.ProgramFilesX86);
        if (Directory.Exists(x86ProgramFiles))
        {
            cleanupTargets.AddRange(Directory.GetDirectories(x86ProgramFiles, "erl*"));
        }

        foreach (var target in cleanupTargets.Distinct(StringComparer.OrdinalIgnoreCase))
        {
            if (!Directory.Exists(target))
            {
                continue;
            }

            try
            {
                Directory.Delete(target, recursive: true);
                await log.WriteAsync($"Deleted folder: {target}");
            }
            catch (Exception ex)
            {
                await log.WriteAsync($"Failed to delete {target}: {ex.Message}");
            }
        }
    }

    private static async Task DownloadFileAsync(string url, string outputPath, RunLogSession log, string label)
    {
        await log.WriteAsync($"Downloading {label} from {url}");

        using var client = new HttpClient
        {
            Timeout = TimeSpan.FromMinutes(5)
        };

        using var response = await client.GetAsync(url);
        response.EnsureSuccessStatusCode();

        await using var stream = await response.Content.ReadAsStreamAsync();
        await using var file = File.Create(outputPath);
        await stream.CopyToAsync(file);

        await log.WriteAsync($"Downloaded {label} installer to {outputPath}");
    }

    private static async Task<int> LaunchInstallerAsync(string installerPath, RunLogSession log)
    {
        var startInfo = new ProcessStartInfo
        {
            FileName = installerPath,
            WorkingDirectory = Path.GetDirectoryName(installerPath) ?? Path.GetTempPath(),
            UseShellExecute = true
        };

        using var process = Process.Start(startInfo);
        if (process is null)
        {
            throw new InvalidOperationException("The installer process could not be started.");
        }

        await log.WriteAsync($"Launched installer: {installerPath}");
        await process.WaitForExitAsync();
        await log.WriteAsync($"Installer closed with exit code {process.ExitCode}.");
        return process.ExitCode;
    }

    private static async Task ConfigureRabbitMqNodeNameAsync(RunLogSession log)
    {
        var userConfigDir = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), "RabbitMQ");
        Directory.CreateDirectory(userConfigDir);
        await File.WriteAllTextAsync(Path.Combine(userConfigDir, "rabbitmq-env-conf.bat"), "set NODENAME=rabbit@localhost");
        await log.WriteAsync($"Wrote nodename config to {userConfigDir}");

        var systemConfigDir = @"C:\Windows\System32\config\systemprofile\AppData\Roaming\RabbitMQ";
        Directory.CreateDirectory(systemConfigDir);
        await File.WriteAllTextAsync(Path.Combine(systemConfigDir, "rabbitmq-env-conf.bat"), "set NODENAME=rabbit@localhost");
        await log.WriteAsync($"Wrote nodename config to {systemConfigDir}");
    }

    private static async Task StartRabbitMqServiceAsync(RunLogSession log)
    {
        using var service = new ServiceController("RabbitMQ");
        await log.WriteAsync("Starting RabbitMQ service.");
        service.Start();
        service.WaitForStatus(ServiceControllerStatus.Running, TimeSpan.FromSeconds(20));
    }

    private static async Task<bool> IsRabbitMqRunningAsync()
    {
        try
        {
            using var service = new ServiceController("RabbitMQ");
            await Task.Delay(1000);
            return service.Status == ServiceControllerStatus.Running;
        }
        catch
        {
            return false;
        }
    }

    private static async Task ExecuteProcessAsync(string fileName, string arguments, RunLogSession log)
    {
        var startInfo = new ProcessStartInfo
        {
            FileName = fileName,
            Arguments = arguments,
            UseShellExecute = false,
            RedirectStandardError = true,
            RedirectStandardOutput = true,
            CreateNoWindow = true
        };

        using var process = new Process
        {
            StartInfo = startInfo
        };

        process.Start();

        var outputTask = DrainReaderAsync(process.StandardOutput, log);
        var errorTask = DrainReaderAsync(process.StandardError, log);

        await process.WaitForExitAsync();
        await Task.WhenAll(outputTask, errorTask);

        if (process.ExitCode != 0)
        {
            throw new InvalidOperationException($"{Path.GetFileName(fileName)} exited with code {process.ExitCode}.");
        }
    }

    private static async Task DrainReaderAsync(StreamReader reader, RunLogSession log)
    {
        while (!reader.EndOfStream)
        {
            var line = await reader.ReadLineAsync();
            if (!string.IsNullOrWhiteSpace(line))
            {
                await log.WriteAsync(line);
            }
        }
    }

    private static void SafeDelete(string path)
    {
        try
        {
            if (File.Exists(path))
            {
                File.Delete(path);
            }
        }
        catch
        {
            // Temp cleanup should never crash the action flow.
        }
    }
}
