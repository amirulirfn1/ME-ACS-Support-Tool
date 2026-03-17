using System.IO;
using System.Windows;
using System.Windows.Threading;

namespace MEACSSupportTool;

public partial class App : Application
{
    public App()
    {
        DispatcherUnhandledException += App_DispatcherUnhandledException;
    }

    private void App_DispatcherUnhandledException(object sender, DispatcherUnhandledExceptionEventArgs e)
    {
        try
        {
            var root = Path.Combine(
                Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
                "MagSupportTool",
                "CrashLogs");
            Directory.CreateDirectory(root);

            var path = Path.Combine(root, $"crash_{DateTime.Now:yyyyMMdd_HHmmss}.log");
            File.WriteAllText(path, e.Exception.ToString());
        }
        catch
        {
            // Avoid crashing the crash handler.
        }
    }
}
