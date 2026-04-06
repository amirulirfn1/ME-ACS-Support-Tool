using System.IO;
using System.Text;

namespace MagDbPatcher.Infrastructure;

public static class DiagnosticsLog
{
    private static readonly string LogPath = AppRuntimePaths.CreateDefault().DiagnosticsLogPath;

    public static string CurrentPath => LogPath;

    public static void Info(string category, string message)
        => Write("info", category, message, ex: null);

    public static void Warning(string category, string message, Exception? ex = null)
        => Write("warning", category, message, ex);

    public static void Error(string category, string message, Exception? ex = null)
        => Write("error", category, message, ex);

    private static void Write(string level, string category, string message, Exception? ex)
    {
        try
        {
            var directory = Path.GetDirectoryName(LogPath);
            if (!string.IsNullOrWhiteSpace(directory))
                Directory.CreateDirectory(directory);

            var builder = new StringBuilder();
            builder.AppendLine("==================================================");
            builder.AppendLine($"timestampUtc={DateTime.UtcNow:O}");
            builder.AppendLine($"level={level}");
            builder.AppendLine($"category={category}");
            builder.AppendLine($"message={message}");
            if (ex != null)
            {
                builder.AppendLine($"exceptionType={ex.GetType().FullName}");
                builder.AppendLine($"exceptionMessage={ex.Message}");
                builder.AppendLine(ex.ToString());
            }

            File.AppendAllText(LogPath, builder.ToString());
        }
        catch
        {
            // Avoid throwing from diagnostics logger.
        }
    }
}
