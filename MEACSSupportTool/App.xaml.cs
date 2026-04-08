using System.IO;
using System.Windows;
using System.Windows.Threading;
using MEACSSupportTool.Infrastructure;

namespace MEACSSupportTool;

public partial class App : System.Windows.Application
{
    private SingleInstanceCoordinator? _singleInstanceCoordinator;

    protected override async void OnStartup(StartupEventArgs e)
    {
        DispatcherUnhandledException += App_DispatcherUnhandledException;
        base.OnStartup(e);

        try
        {
            _singleInstanceCoordinator = new SingleInstanceCoordinator(ActivateMainWindowAsync);

            if (!_singleInstanceCoordinator.IsPrimaryInstance)
            {
                var activated = await _singleInstanceCoordinator.TrySignalPrimaryInstanceAsync(TimeSpan.FromSeconds(2));
                if (!activated)
                {
                    System.Windows.MessageBox.Show(
                        "ME ACS Support Tool is already running, but the existing window could not be brought to the front.\n\nPlease find it in the taskbar.",
                        "Already Running",
                        MessageBoxButton.OK,
                        MessageBoxImage.Information);
                }

                Shutdown(0);
                return;
            }

            _singleInstanceCoordinator.StartListening();

            var mainWindow = new MainWindow();
            MainWindow = mainWindow;
            mainWindow.Show();
        }
        catch (Exception ex)
        {
            System.Windows.MessageBox.Show(
                $"The app failed to start.\n\nError: {ex.Message}",
                "Startup Error",
                MessageBoxButton.OK,
                MessageBoxImage.Error);
            Shutdown(1);
        }
    }

    protected override void OnExit(ExitEventArgs e)
    {
        _singleInstanceCoordinator?.Dispose();
        _singleInstanceCoordinator = null;
        base.OnExit(e);
    }

    private static Task ActivateMainWindowAsync()
    {
        WindowActivationService.BringToFront(Current?.MainWindow);
        return Task.CompletedTask;
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
