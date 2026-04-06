using System.IO;
using System.IO.Pipes;
using System.Security.Cryptography;
using System.Text;

namespace MagDbPatcher.Infrastructure;

public sealed class SingleInstanceCoordinator : IDisposable
{
    private const string ActivationMessage = "ACTIVATE";
    private readonly Func<Task> _activateExistingInstanceAsync;
    private readonly Semaphore _instanceSemaphore;
    private readonly CancellationTokenSource _listenerCancellation = new();
    private readonly string _pipeName;
    private Task? _listenerTask;
    private bool _disposed;

    public SingleInstanceCoordinator(AppRuntimePaths appPaths, Func<Task> activateExistingInstanceAsync)
    {
        ArgumentNullException.ThrowIfNull(appPaths);
        _activateExistingInstanceAsync = activateExistingInstanceAsync ?? throw new ArgumentNullException(nameof(activateExistingInstanceAsync));

        InstanceKey = BuildInstanceKey(appPaths.RootDirectory);
        _pipeName = $"ME_ACS_SQL_Patcher_{InstanceKey}";
        _instanceSemaphore = new Semaphore(1, 1, $@"Local\ME_ACS_SQL_Patcher_{InstanceKey}");
        IsPrimaryInstance = _instanceSemaphore.WaitOne(0, false);
    }

    public bool IsPrimaryInstance { get; }

    public string InstanceKey { get; }

    public void StartListening()
    {
        ThrowIfDisposed();

        if (!IsPrimaryInstance || _listenerTask != null)
            return;

        _listenerTask = Task.Run(() => ListenForActivationAsync(_listenerCancellation.Token));
    }

    public async Task<bool> TrySignalPrimaryInstanceAsync(TimeSpan timeout)
    {
        ThrowIfDisposed();

        try
        {
            using var client = new NamedPipeClientStream(".", _pipeName, PipeDirection.Out, PipeOptions.Asynchronous);
            using var timeoutCancellation = new CancellationTokenSource(timeout);

            await client.ConnectAsync(timeoutCancellation.Token);
            await using var writer = new StreamWriter(client, Encoding.UTF8, 1024, leaveOpen: true) { AutoFlush = true };
            await writer.WriteLineAsync(ActivationMessage);
            return true;
        }
        catch (Exception ex) when (ex is TimeoutException or IOException or OperationCanceledException)
        {
            return false;
        }
    }

    public void Dispose()
    {
        if (_disposed)
            return;

        _disposed = true;
        _listenerCancellation.Cancel();

        try
        {
            _listenerTask?.Wait(TimeSpan.FromSeconds(1));
        }
        catch
        {
            // Ignore shutdown-time listener exceptions.
        }

        _listenerCancellation.Dispose();
        if (IsPrimaryInstance)
            _instanceSemaphore.Release();
        _instanceSemaphore.Dispose();
    }

    public static string BuildInstanceKey(string rootDirectory)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(rootDirectory);

        var normalized = Path.GetFullPath(rootDirectory)
            .TrimEnd(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar)
            .ToUpperInvariant();

        var hash = SHA256.HashData(Encoding.UTF8.GetBytes(normalized));
        return Convert.ToHexString(hash, 0, 16);
    }

    private async Task ListenForActivationAsync(CancellationToken cancellationToken)
    {
        while (!cancellationToken.IsCancellationRequested)
        {
            try
            {
                using var server = new NamedPipeServerStream(
                    _pipeName,
                    PipeDirection.In,
                    1,
                    PipeTransmissionMode.Byte,
                    PipeOptions.Asynchronous);

                await server.WaitForConnectionAsync(cancellationToken);

                using var reader = new StreamReader(server, Encoding.UTF8, detectEncodingFromByteOrderMarks: true, bufferSize: 1024, leaveOpen: true);
                var message = await reader.ReadLineAsync();
                if (string.Equals(message, ActivationMessage, StringComparison.Ordinal))
                    await _activateExistingInstanceAsync();
            }
            catch (OperationCanceledException)
            {
                break;
            }
            catch (ObjectDisposedException)
            {
                break;
            }
            catch (Exception ex)
            {
                DiagnosticsLog.Warning("single-instance-listener", "Failed to process a secondary launch signal.", ex);
                await Task.Delay(250, cancellationToken);
            }
        }
    }

    private void ThrowIfDisposed()
    {
        ObjectDisposedException.ThrowIf(_disposed, this);
    }
}
