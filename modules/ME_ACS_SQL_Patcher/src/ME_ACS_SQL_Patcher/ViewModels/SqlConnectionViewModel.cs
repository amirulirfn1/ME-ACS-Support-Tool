using System.Collections.ObjectModel;
using MagDbPatcher.Models;

namespace MagDbPatcher.ViewModels;

public sealed class SqlConnectionViewModel : BindableBase
{
    private string _server = "";
    private SqlAuthMode _authMode = SqlAuthMode.Windows;
    private string _username = "";
    private string _password = "";
    private string _testResult = "";

    public ObservableCollection<string> Servers { get; } = new();

    public string Server
    {
        get => _server;
        set => SetProperty(ref _server, value);
    }

    public SqlAuthMode AuthMode
    {
        get => _authMode;
        set
        {
            if (!SetProperty(ref _authMode, value))
                return;

            if (_authMode == SqlAuthMode.Windows)
                Password = string.Empty;

            RaisePropertyChanged(nameof(IsSqlLogin));
        }
    }

    public bool IsSqlLogin => AuthMode == SqlAuthMode.SqlLogin;

    public string Username
    {
        get => _username;
        set => SetProperty(ref _username, value);
    }

    public string Password
    {
        get => _password;
        set => SetProperty(ref _password, value);
    }

    public string TestResult
    {
        get => _testResult;
        set => SetProperty(ref _testResult, value);
    }

    public SqlConnectionSettings ToSettings() => new()
    {
        Server = Server.Trim(),
        AuthMode = AuthMode,
        Username = Username.Trim(),
        Password = IsSqlLogin ? Password : null
    };
}
