using System.IO;
using System.IO.Pipes;
using System.Security.Cryptography;
using System.Text;

namespace MEACSSupportTool.Infrastructure;

public sealed class SingleInstanceCoordinator : IDisposable
{
    private const string ActivationMessage = "ACTIVATE";
    private readonly Func<Task> _activateExistingInstanceAsync;
    private readonly Mutex _instanceMutex;
    private readonly CancellationTokenSource _listenerCancellation = new();
    private readonly string _pipeName;
    private Task? _listenerTask;
    private bool _disposed;

    public SingleInstanceCoordinator(Func<Task> activateExistingInstanceAsync)
    {
        _activateExistingInstanceAsync = activateExistingInstanceAsync
            ?? throw new ArgumentNullException(nameof(activateExistingInstanceAsync));

        var key = BuildInstanceKey();
        _pipeName = $"ME_ACS_SupportTool_{key}";
        _instanceMutex = new Mutex(false, $@"Local\ME_ACS_SupportTool_{key}");

        try
        {
            IsPrimaryInstance = _instanceMutex.WaitOne(0, false);
        }
        catch (AbandonedMutexException)
        {
            // Recover cleanly if the previous instance crashed while holding the mutex.
            IsPrimaryInstance = true;
        }
    }

    public bool IsPrimaryInstance { get; }

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
            using var cts = new CancellationTokenSource(timeout);
            await client.ConnectAsync(cts.Token);
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
        {
            try
            {
                _instanceMutex.ReleaseMutex();
            }
            catch (ApplicationException)
            {
                // Mutex ownership is thread-affine. If shutdown resumes on a different thread,
                // process exit will still release the named mutex safely.
            }
        }
        _instanceMutex.Dispose();
    }

    private static string BuildInstanceKey()
    {
        // Key is based on the exe path so each install location is its own instance.
        var exePath = Environment.ProcessPath ?? AppContext.BaseDirectory;
        var normalized = Path.GetFullPath(exePath).ToUpperInvariant();
        var hash = SHA256.HashData(Encoding.UTF8.GetBytes(normalized));
        return Convert.ToHexString(hash, 0, 8);
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

                using var reader = new StreamReader(server, Encoding.UTF8,
                    detectEncodingFromByteOrderMarks: true, bufferSize: 1024, leaveOpen: true);
                var message = await reader.ReadLineAsync(cancellationToken);
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
            catch
            {
                // Keep listening after transient pipe errors.
                await Task.Delay(250, cancellationToken).ConfigureAwait(false);
            }
        }
    }

    private void ThrowIfDisposed()
    {
        ObjectDisposedException.ThrowIf(_disposed, this);
    }
}
