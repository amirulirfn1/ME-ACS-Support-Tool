using System.IO;
using System.Text;
using System.Windows;
using System.Windows.Threading;
using MagDbPatcher.Infrastructure;
using MagDbPatcher.Services;

namespace MagDbPatcher;

public partial class App : Application
{
    private static readonly AppRuntimePaths AppPaths = AppRuntimePaths.CreateDefault();
    private static readonly string ErrorLogPath = AppPaths.StartupErrorLogPath;
    private SingleInstanceCoordinator? _singleInstanceCoordinator;

    protected override async void OnStartup(StartupEventArgs e)
    {
        RegisterGlobalExceptionHandlers();
        base.OnStartup(e);
        StartupWindow? startupWindow = null;

        try
        {
            _singleInstanceCoordinator = new SingleInstanceCoordinator(AppPaths, ActivateMainWindowAsync);
            if (!_singleInstanceCoordinator.IsPrimaryInstance)
            {
                var activatedExistingWindow = await _singleInstanceCoordinator.TrySignalPrimaryInstanceAsync(TimeSpan.FromSeconds(2));
                if (!activatedExistingWindow)
                {
                    MessageBox.Show(
                        "ME_ACS SQL Patcher is already running, but the existing window could not be activated.\n\n" +
                        "Please bring the existing app window to the front manually.",
                        "Already Running",
                        MessageBoxButton.OK,
                        MessageBoxImage.Information);
                }

                Shutdown(0);
                return;
            }

            _singleInstanceCoordinator.StartListening();
            DiagnosticsLog.Info("startup", $"Primary instance started. Root={AppPaths.RootDirectory}");

            startupWindow = new StartupWindow();
            startupWindow.Show();
            startupWindow.UpdateStatus("Checking installed workspace...");

            var bootstrap = new PortableAppBootstrapService(AppPaths);
            await bootstrap.EnsureReadyAsync(new Progress<string>(message => startupWindow.UpdateStatus(message)));

            startupWindow.UpdateStatus("Opening the patch dashboard...");
            var mainWindow = new MainWindow(AppPaths);
            MainWindow = mainWindow;
            mainWindow.Show();
            WindowActivationService.BringToFront(mainWindow);
            startupWindow.Close();
            startupWindow = null;
        }
        catch (Exception ex)
        {
            startupWindow?.Close();
            DiagnosticsLog.Error("startup", "Application startup failed.", ex);
            LogException("OnStartup", ex);
            MessageBox.Show(
                "The app failed to start.\n\n" +
                $"Details were saved to:\n{ErrorLogPath}\n\n" +
                $"Error: {ex.Message}",
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

    private void RegisterGlobalExceptionHandlers()
    {
        DispatcherUnhandledException += OnDispatcherUnhandledException;
        AppDomain.CurrentDomain.UnhandledException += OnUnhandledException;
        TaskScheduler.UnobservedTaskException += OnUnobservedTaskException;
    }

    private void OnDispatcherUnhandledException(object sender, DispatcherUnhandledExceptionEventArgs e)
    {
        DiagnosticsLog.Error("dispatcher", "Unhandled UI exception.", e.Exception);
        LogException("DispatcherUnhandledException", e.Exception);
        MessageBox.Show(
            "A fatal UI error occurred.\n\n" +
            $"Details were saved to:\n{ErrorLogPath}\n\n" +
            $"Error: {e.Exception.Message}",
            "Application Error",
            MessageBoxButton.OK,
            MessageBoxImage.Error);
        e.Handled = true;
        Shutdown(1);
    }

    private void OnUnhandledException(object? sender, UnhandledExceptionEventArgs e)
    {
        var ex = e.ExceptionObject as Exception ?? new Exception("Unknown unhandled exception.");
        DiagnosticsLog.Error("app-domain", "Unhandled non-UI exception.", ex);
        LogException("AppDomainUnhandledException", ex);
    }

    private void OnUnobservedTaskException(object? sender, UnobservedTaskExceptionEventArgs e)
    {
        DiagnosticsLog.Error("task", "Unobserved task exception.", e.Exception);
        LogException("UnobservedTaskException", e.Exception);
        e.SetObserved();
    }

    private static Task ActivateMainWindowAsync()
    {
        WindowActivationService.BringToFront(Current?.MainWindow);
        return Task.CompletedTask;
    }

    private static void LogException(string source, Exception ex)
    {
        try
        {
            var directory = Path.GetDirectoryName(ErrorLogPath);
            if (!string.IsNullOrWhiteSpace(directory))
            {
                Directory.CreateDirectory(directory);
            }

            var builder = new StringBuilder();
            builder.AppendLine("==================================================");
            builder.AppendLine($"Timestamp: {DateTime.Now:yyyy-MM-dd HH:mm:ss}");
            builder.AppendLine($"Source: {source}");
            builder.AppendLine($"Message: {ex.Message}");
            builder.AppendLine("StackTrace:");
            builder.AppendLine(ex.ToString());

            File.AppendAllText(ErrorLogPath, builder.ToString());
        }
        catch
        {
            // Avoid secondary failures while reporting crashes.
        }
    }
}
