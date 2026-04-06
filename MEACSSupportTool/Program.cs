using System;
using System.ComponentModel;
using System.Diagnostics;
using System.Linq;
using System.Security.Principal;
using System.Windows;
using Velopack;

namespace MEACSSupportTool;

public static class Program
{
    [STAThread]
    public static void Main()
    {
        var args = Environment.GetCommandLineArgs().Skip(1).ToArray();

        // Velopack install/update hooks must return quickly and should not trigger UAC relaunches.
        if (IsVelopackHookInvocation(args))
        {
            VelopackApp.Build()
                .SetAutoApplyOnStartup(false)
                .Run();

            return;
        }

        if (!IsAdministrator())
        {
            if (TryRelaunchElevated())
            {
                return;
            }

            System.Windows.MessageBox.Show(
                "ME ACS Support Tool needs Administrator access to run support actions safely. Reopen the app and approve the Windows UAC prompt.",
                "Administrator Access Needed",
                MessageBoxButton.OK,
                MessageBoxImage.Information);
            return;
        }

        VelopackApp.Build()
            .SetAutoApplyOnStartup(false)
            .Run();

        var app = new App();
        app.InitializeComponent();
        app.Run();
    }

    private static bool IsAdministrator()
    {
        using var identity = WindowsIdentity.GetCurrent();
        var principal = new WindowsPrincipal(identity);
        return principal.IsInRole(WindowsBuiltInRole.Administrator);
    }

    private static bool TryRelaunchElevated()
    {
        var executablePath = Environment.ProcessPath;
        if (string.IsNullOrWhiteSpace(executablePath))
        {
            return false;
        }

        try
        {
            Process.Start(new ProcessStartInfo
            {
                FileName = executablePath,
                Arguments = BuildArgumentString(Environment.GetCommandLineArgs().Skip(1)),
                UseShellExecute = true,
                Verb = "runas",
                WorkingDirectory = AppContext.BaseDirectory
            });

            return true;
        }
        catch (Win32Exception ex) when (ex.NativeErrorCode == 1223)
        {
            // User cancelled the UAC prompt. Exit quietly so setup hooks do not fail noisily.
            return false;
        }
    }

    private static bool IsVelopackHookInvocation(IEnumerable<string> args)
        => args.Any(arg => arg.StartsWith("--veloapp-", StringComparison.OrdinalIgnoreCase));

    private static string BuildArgumentString(IEnumerable<string> args)
        => string.Join(" ", args.Select(QuoteArgument));

    private static string QuoteArgument(string arg)
    {
        if (string.IsNullOrEmpty(arg))
        {
            return "\"\"";
        }

        if (!arg.Any(ch => char.IsWhiteSpace(ch) || ch == '"'))
        {
            return arg;
        }

        return "\"" + arg.Replace("\\", "\\\\").Replace("\"", "\\\"") + "\"";
    }
}
