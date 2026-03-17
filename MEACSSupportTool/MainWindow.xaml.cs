using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Diagnostics;
using System.IO;
using System.Runtime.CompilerServices;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;
using MEACSSupportTool.Models;
using MEACSSupportTool.Services;

namespace MEACSSupportTool;

public partial class MainWindow : Window, INotifyPropertyChanged
{
    private readonly LoggingService _loggingService;
    private readonly SupportEnvironmentService _environmentService;
    private readonly SupportActionRunner _actionRunner;

    private bool _isBusy;
    private string _machineName = "Loading...";
    private string _currentUser = "Loading...";
    private string _adminStatus = "Checking...";
    private string _internetStatus = "Checking...";
    private string _rabbitMqStatus = "Checking...";
    private string _ssmsStatus = "Checking...";
    private string _sqlStatus = "Checking...";
    private string _databaseStatus = "Checking...";
    private string _lastRefreshText = "Never";
    private string _statusBanner = "Ready for the next support action.";
    private string _liveLogText = "Open the tool and refresh machine status before running a repair.";
    private bool _activityConsoleExpanded;
    private string? _currentLogFilePath;

    public MainWindow()
    {
        InitializeComponent();
        DataContext = this;

        _loggingService = new LoggingService();
        _environmentService = new SupportEnvironmentService();

        var sqlScriptPath = Path.Combine(AppContext.BaseDirectory, "Assets", "Sql", "Solve Client Lag Issues.sql");
        _actionRunner = new SupportActionRunner(_environmentService, sqlScriptPath);

        HistoryItems = new ObservableCollection<HistoryRecord>(_loggingService.LoadHistory());
        LogRootDirectory = _loggingService.RootDirectory;

        Loaded += MainWindow_Loaded;
    }

    public event PropertyChangedEventHandler? PropertyChanged;

    public ObservableCollection<HistoryRecord> HistoryItems { get; }

    public string MachineName
    {
        get => _machineName;
        private set => SetField(ref _machineName, value);
    }

    public string CurrentUser
    {
        get => _currentUser;
        private set => SetField(ref _currentUser, value);
    }

    public string AdminStatus
    {
        get => _adminStatus;
        private set => SetField(ref _adminStatus, value);
    }

    public string InternetStatus
    {
        get => _internetStatus;
        private set => SetField(ref _internetStatus, value);
    }

    public string RabbitMqStatus
    {
        get => _rabbitMqStatus;
        private set => SetField(ref _rabbitMqStatus, value);
    }

    public string SsmsStatus
    {
        get => _ssmsStatus;
        private set => SetField(ref _ssmsStatus, value);
    }

    public string SqlStatus
    {
        get => _sqlStatus;
        private set => SetField(ref _sqlStatus, value);
    }

    public string DatabaseStatus
    {
        get => _databaseStatus;
        private set => SetField(ref _databaseStatus, value);
    }

    public string LastRefreshText
    {
        get => _lastRefreshText;
        private set => SetField(ref _lastRefreshText, value);
    }

    public string StatusBanner
    {
        get => _statusBanner;
        private set => SetField(ref _statusBanner, value);
    }

    public string LiveLogText
    {
        get => _liveLogText;
        private set => SetField(ref _liveLogText, value);
    }

    public bool ActivityConsoleExpanded
    {
        get => _activityConsoleExpanded;
        private set => SetField(ref _activityConsoleExpanded, value);
    }

    public string LogRootDirectory { get; }

    public bool IsNotBusy => !_isBusy;

    public bool CanOpenCurrentLog => !string.IsNullOrWhiteSpace(_currentLogFilePath) && File.Exists(_currentLogFilePath);

    private async void MainWindow_Loaded(object sender, RoutedEventArgs e)
    {
        await RefreshStatusAsync();
    }

    private async void RefreshStatusButton_Click(object sender, RoutedEventArgs e)
    {
        await RefreshStatusAsync();
    }

    private async void RunRabbitMqRepairButton_Click(object sender, RoutedEventArgs e)
    {
        var confirmation = MessageBox.Show(
            "RabbitMQ Repair will uninstall and reinstall RabbitMQ and Erlang on this PC.\n\nDo you want to continue?",
            "Confirm RabbitMQ Repair",
            MessageBoxButton.YesNo,
            MessageBoxImage.Warning);

        if (confirmation != MessageBoxResult.Yes)
        {
            return;
        }

        await RunActionAsync("rabbitmq-repair", "RabbitMQ Repair", _actionRunner.RunRabbitMqRepairAsync);
    }

    private async void RunSolveClientLagButton_Click(object sender, RoutedEventArgs e)
    {
        await RunActionAsync("solve-client-lag", "Solve Client Lag", _actionRunner.RunSolveClientLagAsync);
    }

    private async void RunInstallSsmsButton_Click(object sender, RoutedEventArgs e)
    {
        var confirmation = MessageBox.Show(
            "Install SSMS will download the full SQL Server Management Studio installer and open it on this PC.\n\nDo you want to continue?",
            "Confirm Install SSMS",
            MessageBoxButton.YesNo,
            MessageBoxImage.Question);

        if (confirmation != MessageBoxResult.Yes)
        {
            return;
        }

        await RunActionAsync("install-ssms", "Install SSMS", _actionRunner.RunInstallSsmsAsync);
    }

    private void OpenLogsFolderButton_Click(object sender, RoutedEventArgs e)
    {
        OpenPath(_loggingService.LogsDirectory);
    }

    private void OpenCurrentLogButton_Click(object sender, RoutedEventArgs e)
    {
        if (string.IsNullOrWhiteSpace(_currentLogFilePath) || !File.Exists(_currentLogFilePath))
        {
            MessageBox.Show("There is no current log file to open yet.", "Open Current Log", MessageBoxButton.OK, MessageBoxImage.Information);
            return;
        }

        OpenPath(_currentLogFilePath);
    }

    private async Task RefreshStatusAsync(bool manageBusy = true, bool updateStatusBanner = true)
    {
        if (manageBusy)
        {
            SetBusy(true);
        }

        if (updateStatusBanner)
        {
            StatusBanner = "Refreshing local machine checks...";
        }

        try
        {
            var snapshot = await _environmentService.GetSnapshotAsync();
            MachineName = snapshot.MachineName;
            CurrentUser = snapshot.CurrentUser;
            AdminStatus = snapshot.IsAdministrator ? "Ready" : "Not running as Administrator";
            InternetStatus = snapshot.HasInternetAccess ? "Online" : "Offline or blocked";
            RabbitMqStatus = snapshot.RabbitMqInstalled
                ? (snapshot.RabbitMqRunning ? "Installed and running" : "Installed but stopped")
                : "Not installed";
            SsmsStatus = snapshot.SsmsInstalled ? "Installed" : "Not installed";
            SqlStatus = snapshot.SqlReachable
                ? $"Connected ({snapshot.SqlDataSource})"
                : "Local SQL not detected";
            DatabaseStatus = snapshot.MagEtegraDatabaseExists
                ? "magetegra is present"
                : "magetegra not found";
            LastRefreshText = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss");
            if (updateStatusBanner)
            {
                StatusBanner = "Machine status refreshed.";
            }
        }
        catch (Exception ex)
        {
            StatusBanner = $"Refresh failed: {ex.Message}";
        }
        finally
        {
            if (manageBusy)
            {
                SetBusy(false);
            }
        }
    }

    private async Task RunActionAsync(string actionId, string actionName, Func<RunLogSession, Task<RunResult>> runner)
    {
        SetBusy(true);
        StatusBanner = $"Running {actionName}...";
        LiveLogText = string.Empty;
        ActivityConsoleExpanded = true;

        var startedAt = DateTime.Now;
        RunLogSession? session = null;
        try
        {
            session = _loggingService.CreateSession(actionId, actionName);
            _currentLogFilePath = session.LogFilePath;
            OnPropertyChanged(nameof(CanOpenCurrentLog));

            session.LineWritten += AppendLiveLogLine;

            await session.WriteAsync($"Machine: {Environment.MachineName}");
            await session.WriteAsync($"User: {Environment.UserName}");
            var result = await runner(session);
            await session.WriteAsync($"Finished with outcome: {result.Outcome}");
            await session.WriteAsync(result.Summary);

            var history = new HistoryRecord
            {
                RunId = session.RunId,
                ActionId = actionId,
                ActionName = actionName,
                MachineName = Environment.MachineName,
                UserName = Environment.UserName,
                StartedAt = startedAt,
                EndedAt = DateTime.Now,
                Outcome = result.Outcome,
                Summary = result.Summary,
                LogFilePath = session.LogFilePath
            };

            await _loggingService.SaveHistoryAsync(history);
            HistoryItems.Insert(0, history);
            while (HistoryItems.Count > 20)
            {
                HistoryItems.RemoveAt(HistoryItems.Count - 1);
            }

            await RefreshStatusAsync(manageBusy: false, updateStatusBanner: false);
            StatusBanner = $"{actionName}: {result.Summary}";

            if (result.Outcome == RunOutcome.Failed)
            {
                MessageBox.Show(result.Summary, actionName, MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }
        catch (Exception ex)
        {
            StatusBanner = $"{actionName}: {ex.Message}";

            if (session is not null)
            {
                try
                {
                    await session.WriteAsync($"Unhandled error: {ex}");
                }
                catch
                {
                    // Keep the UI usable even if logging also fails.
                }
            }

            MessageBox.Show(ex.Message, actionName, MessageBoxButton.OK, MessageBoxImage.Error);
        }
        finally
        {
            if (session is not null)
            {
                await session.DisposeAsync();
            }

            SetBusy(false);
        }
    }

    private static void OpenPath(string path)
    {
        Process.Start(new ProcessStartInfo
        {
            FileName = path,
            UseShellExecute = true
        });
    }

    private void HistoryGrid_MouseDoubleClick(object sender, MouseButtonEventArgs e)
    {
        if (sender is not DataGrid grid || grid.SelectedItem is not HistoryRecord record)
        {
            return;
        }

        if (!File.Exists(record.LogFilePath))
        {
            MessageBox.Show("The selected run log could not be found.", "Open Run Log", MessageBoxButton.OK, MessageBoxImage.Information);
            return;
        }

        OpenPath(record.LogFilePath);
    }

    private void SetBusy(bool isBusy)
    {
        _isBusy = isBusy;
        OnPropertyChanged(nameof(IsNotBusy));
    }

    private void AppendLiveLogLine(string line)
    {
        Dispatcher.Invoke(() =>
        {
            const int maxLogCharacters = 24000;
            var nextValue = string.Concat(LiveLogText, line, Environment.NewLine);
            if (nextValue.Length > maxLogCharacters)
            {
                nextValue = nextValue[^maxLogCharacters..];
            }

            LiveLogText = nextValue;
        });
    }

    private void SetField<T>(ref T field, T value, [CallerMemberName] string? propertyName = null)
    {
        if (EqualityComparer<T>.Default.Equals(field, value))
        {
            return;
        }

        field = value;
        OnPropertyChanged(propertyName);
    }

    private void OnPropertyChanged([CallerMemberName] string? propertyName = null)
    {
        PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
    }
}
