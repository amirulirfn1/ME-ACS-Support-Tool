using System.IO;
using System.Text;

namespace MagDbPatcher.Infrastructure;

public sealed class SessionLog
{
    private readonly string _logFilePath;
    private readonly object _sync = new();

    public SessionLog(AppRuntimePaths appPaths)
    {
        ArgumentNullException.ThrowIfNull(appPaths);

        Directory.CreateDirectory(appPaths.LogsDirectory);
        _logFilePath = Path.Combine(appPaths.LogsDirectory, $"session_{DateTime.Now:yyyyMMdd_HHmmss}.log");
    }

    public string LogFilePath => _logFilePath;

    public void WriteLine(string message)
    {
        try
        {
            lock (_sync)
            {
                File.AppendAllText(_logFilePath, message + Environment.NewLine, Encoding.UTF8);
            }
        }
        catch
        {
            // Avoid secondary failures while logging session details.
        }
    }
}
