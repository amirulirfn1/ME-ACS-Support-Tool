namespace MagDbPatcher.Models;

public class SqlConnectionSettings
{
    public string Server { get; set; } = "";
    public SqlAuthMode AuthMode { get; set; } = SqlAuthMode.Windows;
    public string? Username { get; set; }
    public string? Password { get; set; }
}
