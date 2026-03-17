using System.IO;
using System.Text;

namespace MEACSSupportTool.Services;

public sealed class RunLogSession : IAsyncDisposable
{
    private readonly StreamWriter _writer;
    private readonly SemaphoreSlim _gate = new(1, 1);

    public RunLogSession(string runId, string actionId, string actionName, string logFilePath)
    {
        RunId = runId;
        ActionId = actionId;
        ActionName = actionName;
        LogFilePath = logFilePath;

        Directory.CreateDirectory(Path.GetDirectoryName(logFilePath)!);
        _writer = new StreamWriter(logFilePath, append: false, Encoding.UTF8);
    }

    public string RunId { get; }

    public string ActionId { get; }

    public string ActionName { get; }

    public string LogFilePath { get; }

    public event Action<string>? LineWritten;

    public async Task WriteAsync(string message)
    {
        var line = $"{DateTime.Now:HH:mm:ss} {message}";

        await _gate.WaitAsync();
        try
        {
            await _writer.WriteLineAsync(line);
            await _writer.FlushAsync();
        }
        finally
        {
            _gate.Release();
        }

        LineWritten?.Invoke(line);
    }

    public async ValueTask DisposeAsync()
    {
        await _gate.WaitAsync();
        try
        {
            await _writer.FlushAsync();
            _writer.Dispose();
        }
        finally
        {
            _gate.Release();
            _gate.Dispose();
        }
    }
}
