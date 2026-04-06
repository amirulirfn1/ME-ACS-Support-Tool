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
    private const string SupportUserName = "magetegra";
    private const string SupportUserPassword = "11398MEacs";
    private const string SupportUserFullName = "MagEtegra";
    private const string SupportUserDescription = "MagEtegra Service Account";
    private const string SsmsInstallerUrl = "https://aka.ms/ssmsfullsetup";
    private const string RabbitMqServiceName = "RabbitMQ";
    private static readonly TimeSpan RabbitMqStopTimeout = TimeSpan.FromSeconds(90);
    private static readonly TimeSpan RabbitMqStartTimeout = TimeSpan.FromSeconds(120);
    private static readonly TimeSpan RabbitMqServiceRegistrationTimeout = TimeSpan.FromSeconds(60);
    private static readonly TimeSpan ServicePollInterval = TimeSpan.FromSeconds(2);
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

            await StopProcessesAsync(log, ["MagServer"]);
            await StopRabbitMqServiceAsync(log);
            await StopProcessesAsync(log, ["erl", "epmd"]);
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
            await WaitForRabbitMqServiceToExistAsync(log);
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
        catch (RabbitMqRepairException ex)
        {
            await log.WriteAsync(ex.Message);
            return new RunResult
            {
                Outcome = RunOutcome.Failed,
                Summary = ex.UserMessage
            };
        }
        catch (Exception ex)
        {
            await log.WriteAsync($"RabbitMQ repair failed unexpectedly: {ex.Message}");
            return new RunResult
            {
                Outcome = RunOutcome.Failed,
                Summary = "RabbitMQ Repair hit an unexpected error. Check the run log for the exact step that failed."
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
            await LaunchInstallerAsync(installerPath, log);
            await log.WriteAsync("SSMS installer launched successfully. Complete the setup wizard to finish installation.");
            return new RunResult
            {
                Outcome = RunOutcome.Success,
                Summary = "SSMS installer downloaded and opened. Finish the installation wizard to complete setup."
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

    public async Task<RunResult> RunEnsureSupportUserAsync(RunLogSession log)
    {
        await log.WriteAsync($"Ensuring local support account '{SupportUserName}' exists and is configured.");

        if (!IsAdministrator())
        {
            await log.WriteAsync("Blocked because the app is not running as Administrator.");
            return new RunResult
            {
                Outcome = RunOutcome.Failed,
                Summary = "Run the tool as Administrator before creating the local support account."
            };
        }

        try
        {
            await ExecutePowerShellScriptAsync($$"""
$ErrorActionPreference = 'Stop'
$username = '{{SupportUserName}}'
$plainPassword = '{{SupportUserPassword}}'
$fullName = '{{SupportUserFullName}}'
$description = '{{SupportUserDescription}}'
$securePassword = ConvertTo-SecureString $plainPassword -AsPlainText -Force

$existingUser = Get-LocalUser -Name $username -ErrorAction SilentlyContinue
if ($null -eq $existingUser) {
    New-LocalUser -Name $username `
                  -Password $securePassword `
                  -FullName $fullName `
                  -Description $description `
                  -PasswordNeverExpires `
                  -UserMayNotChangePassword | Out-Null
    Write-Output "Created local user $username."
} else {
    Set-LocalUser -Name $username `
                  -Password $securePassword `
                  -FullName $fullName `
                  -Description $description `
                  -PasswordNeverExpires $true `
                  -UserMayChangePassword $false | Out-Null
    Write-Output "Updated existing local user $username."
}

Enable-LocalUser -Name $username -ErrorAction SilentlyContinue
Write-Output "Ensured $username is enabled."

$adminMember = Get-LocalGroupMember -Group 'Administrators' -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -match "(^|\\\\)$([regex]::Escape($username))$" }
if ($null -eq $adminMember) {
    Add-LocalGroupMember -Group 'Administrators' -Member $username
    Write-Output "Added $username to the Administrators group."
} else {
    Write-Output "$username is already in the Administrators group."
}

& net.exe user $username $plainPassword /passwordchg:no /expires:never
if ($LASTEXITCODE -ne 0) {
    throw "net user failed with exit code $LASTEXITCODE while enforcing password policy."
}

Write-Output "Password policy set: user cannot change password, password never expires."
""", log);

            await log.WriteAsync($"Local support account '{SupportUserName}' is ready.");
            return new RunResult
            {
                Outcome = RunOutcome.Success,
                Summary = $"Local user '{SupportUserName}' is ready, is an Administrator, and has a non-expiring password."
            };
        }
        catch (Exception ex)
        {
            await log.WriteAsync($"Failed to configure local support account: {ex.Message}");
            return new RunResult
            {
                Outcome = RunOutcome.Failed,
                Summary = $"Could not create or update local user '{SupportUserName}'. Check the run log for the failing step."
            };
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
                    if (!process.WaitForExit(10000))
                    {
                        await log.WriteAsync($"Process {process.ProcessName}.exe (PID {process.Id}) is still shutting down.");
                        continue;
                    }

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
            using var service = new ServiceController(RabbitMqServiceName);
            service.Refresh();
            if (service.Status == ServiceControllerStatus.Stopped)
            {
                await log.WriteAsync("RabbitMQ service is already stopped.");
                return;
            }

            await log.WriteAsync($"Stopping RabbitMQ service from state {service.Status}.");
            if (service.Status != ServiceControllerStatus.StopPending)
            {
                service.Stop();
            }

            try
            {
                await WaitForServiceStatusAsync(service, ServiceControllerStatus.Stopped, RabbitMqStopTimeout, log, "stopping");
            }
            catch (RabbitMqRepairException)
            {
                await log.WriteAsync("RabbitMQ stop timed out. Forcing Erlang-related processes down and retrying once.");
                await StopProcessesAsync(log, ["erl", "epmd"]);

                service.Refresh();
                if (service.Status != ServiceControllerStatus.Stopped)
                {
                    if (service.Status != ServiceControllerStatus.StopPending)
                    {
                        service.Stop();
                    }

                    await WaitForServiceStatusAsync(service, ServiceControllerStatus.Stopped, TimeSpan.FromSeconds(45), log, "stopping after force-close");
                }
            }
        }
        catch (InvalidOperationException)
        {
            await log.WriteAsync("RabbitMQ service is not installed.");
        }
    }

    private static async Task UninstallRabbitMqAsync(RunLogSession log)
    {
        var uninstallPath = FindRabbitMqUninstallerPath();
        if (string.IsNullOrWhiteSpace(uninstallPath) || !File.Exists(uninstallPath))
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
        foreach (var root in GetProgramFilesRoots())
        {
            var canonical = Path.Combine(root, "Erlang OTP", "Uninstall.exe");
            if (File.Exists(canonical))
            {
                uninstallers.Add(canonical);
            }

            if (Directory.Exists(root))
            {
                uninstallers.AddRange(Directory.GetDirectories(root, "erl*")
                    .Select(path => Path.Combine(path, "Uninstall.exe"))
                    .Where(File.Exists));
            }
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
            Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ProgramFilesX86), "RabbitMQ Server"),
            Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ProgramFiles), "Erlang OTP"),
            Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ProgramFilesX86), "Erlang OTP"),
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

        using var response = await client.GetAsync(url, HttpCompletionOption.ResponseHeadersRead);
        response.EnsureSuccessStatusCode();

        var totalBytes = response.Content.Headers.ContentLength;
        await using var stream = await response.Content.ReadAsStreamAsync();
        await using var file = File.Create(outputPath);
        var buffer = new byte[81920];
        long totalRead = 0;
        var nextPercentToReport = 0;
        var nextBytesToReport = 5L * 1024 * 1024;

        while (true)
        {
            var read = await stream.ReadAsync(buffer);
            if (read == 0)
            {
                break;
            }

            await file.WriteAsync(buffer.AsMemory(0, read));
            totalRead += read;

            if (totalBytes.HasValue && totalBytes.Value > 0)
            {
                var percent = (int)Math.Floor(totalRead * 100d / totalBytes.Value);
                if (percent >= nextPercentToReport)
                {
                    await log.WriteAsync(
                        $"Download progress - {label}: {Math.Min(percent, 100)}% ({FormatBytes(totalRead)} / {FormatBytes(totalBytes.Value)})");
                    nextPercentToReport = Math.Min(100, nextPercentToReport + 5);
                }
            }
            else if (totalRead >= nextBytesToReport)
            {
                await log.WriteAsync($"Download progress - {label}: {FormatBytes(totalRead)} downloaded");
                nextBytesToReport += 5L * 1024 * 1024;
            }
        }

        if (totalBytes.HasValue && totalBytes.Value > 0 && nextPercentToReport <= 100)
        {
            await log.WriteAsync(
                $"Download progress - {label}: 100% ({FormatBytes(totalRead)} / {FormatBytes(totalBytes.Value)})");
        }
        else if (!totalBytes.HasValue)
        {
            await log.WriteAsync($"Download progress - {label}: completed ({FormatBytes(totalRead)})");
        }

        await log.WriteAsync($"Downloaded {label} installer to {outputPath}");
    }

    private static string FormatBytes(long bytes)
    {
        string[] units = ["B", "KB", "MB", "GB"];
        double value = bytes;
        var unitIndex = 0;

        while (value >= 1024 && unitIndex < units.Length - 1)
        {
            value /= 1024;
            unitIndex++;
        }

        return $"{value:0.#} {units[unitIndex]}";
    }

    private static Task LaunchInstallerAsync(string installerPath, RunLogSession log)
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

        return log.WriteAsync($"Launched installer: {installerPath}");
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
        using var service = new ServiceController(RabbitMqServiceName);
        service.Refresh();
        if (service.Status == ServiceControllerStatus.Running)
        {
            await log.WriteAsync("RabbitMQ service is already running.");
            return;
        }

        await log.WriteAsync($"Starting RabbitMQ service from state {service.Status}.");
        if (service.Status != ServiceControllerStatus.StartPending)
        {
            service.Start();
        }

        await WaitForServiceStatusAsync(service, ServiceControllerStatus.Running, RabbitMqStartTimeout, log, "starting");
    }

    private static async Task<bool> IsRabbitMqRunningAsync()
    {
        try
        {
            using var service = new ServiceController(RabbitMqServiceName);
            await Task.Delay(1000);
            service.Refresh();
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

    private static async Task ExecutePowerShellScriptAsync(string scriptContent, RunLogSession log)
    {
        var scriptPath = Path.Combine(Path.GetTempPath(), $"me-acs-support-{Guid.NewGuid():N}.ps1");
        try
        {
            await File.WriteAllTextAsync(scriptPath, scriptContent);
            await ExecuteProcessAsync(
                "powershell.exe",
                $"-NoProfile -ExecutionPolicy Bypass -File \"{scriptPath}\"",
                log);
        }
        finally
        {
            SafeDelete(scriptPath);
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

    private static async Task WaitForRabbitMqServiceToExistAsync(RunLogSession log)
    {
        var sw = Stopwatch.StartNew();
        while (sw.Elapsed < RabbitMqServiceRegistrationTimeout)
        {
            if (ServiceController.GetServices()
                .Any(service => service.ServiceName.Equals(RabbitMqServiceName, StringComparison.OrdinalIgnoreCase)))
            {
                await log.WriteAsync("RabbitMQ service registration detected.");
                return;
            }

            await Task.Delay(ServicePollInterval);
        }

        throw new RabbitMqRepairException(
            $"RabbitMQ service was not registered within {RabbitMqServiceRegistrationTimeout.TotalSeconds:0} seconds after installation.",
            "RabbitMQ installed, but its Windows service was not registered in time. Reboot the PC and rerun RabbitMQ Repair.");
    }

    private static async Task WaitForServiceStatusAsync(
        ServiceController service,
        ServiceControllerStatus targetStatus,
        TimeSpan timeout,
        RunLogSession log,
        string operation)
    {
        var sw = Stopwatch.StartNew();
        while (sw.Elapsed < timeout)
        {
            service.Refresh();
            if (service.Status == targetStatus)
            {
                await log.WriteAsync($"RabbitMQ service reached {targetStatus} after {sw.Elapsed.TotalSeconds:0} seconds.");
                return;
            }

            await Task.Delay(ServicePollInterval);
        }

        service.Refresh();
        throw new RabbitMqRepairException(
            $"RabbitMQ service did not reach {targetStatus} within {timeout.TotalSeconds:0} seconds while {operation}. Current state: {service.Status}.",
            targetStatus == ServiceControllerStatus.Stopped
                ? "RabbitMQ took too long to stop. Close MagServer, wait a moment, and retry. If it keeps hanging, reboot the PC first."
                : "RabbitMQ took too long to start. Wait a moment and retry. If it still fails, reboot the PC and rerun RabbitMQ Repair.");
    }

    private static string? FindRabbitMqUninstallerPath()
    {
        foreach (var root in GetProgramFilesRoots())
        {
            var uninstallPath = Path.Combine(root, "RabbitMQ Server", "uninstall.exe");
            if (File.Exists(uninstallPath))
            {
                return uninstallPath;
            }
        }

        return null;
    }

    private static IEnumerable<string> GetProgramFilesRoots()
    {
        var roots = new[]
        {
            Environment.GetFolderPath(Environment.SpecialFolder.ProgramFiles),
            Environment.GetFolderPath(Environment.SpecialFolder.ProgramFilesX86)
        };

        return roots
            .Where(path => !string.IsNullOrWhiteSpace(path))
            .Distinct(StringComparer.OrdinalIgnoreCase);
    }
}

internal sealed class RabbitMqRepairException : Exception
{
    public RabbitMqRepairException(string message, string userMessage)
        : base(message)
    {
        UserMessage = userMessage;
    }

    public string UserMessage { get; }
}
