using System.IO;
using System.Text.Json;
using MEACSSupportTool.Models;

namespace MEACSSupportTool.Services;

public sealed class LoggingService
{
    private readonly JsonSerializerOptions _jsonOptions = new(JsonSerializerDefaults.Web);

    public LoggingService()
    {
        RootDirectory = ResolveRootDirectory();
        LogsDirectory = Path.Combine(RootDirectory, "Logs");
        HistoryDirectory = Path.Combine(RootDirectory, "History");
        HistoryFilePath = Path.Combine(HistoryDirectory, "history.jsonl");

        Directory.CreateDirectory(LogsDirectory);
        Directory.CreateDirectory(HistoryDirectory);
    }

    public string RootDirectory { get; }

    public string LogsDirectory { get; }

    public string HistoryDirectory { get; }

    public string HistoryFilePath { get; }

    public RunLogSession CreateSession(string actionId, string actionName)
    {
        var runId = $"{DateTime.Now:yyyyMMddHHmmss}-{Guid.NewGuid():N}"[..24];
        var safeActionName = string.Concat(actionName.Select(ch => Path.GetInvalidFileNameChars().Contains(ch) ? '_' : ch));
        var logFileName = $"{DateTime.Now:yyyyMMdd_HHmmss}_{safeActionName}_{runId}.log";
        var logPath = Path.Combine(LogsDirectory, logFileName);

        return new RunLogSession(runId, actionId, actionName, logPath);
    }

    public async Task SaveHistoryAsync(HistoryRecord record)
    {
        var payload = JsonSerializer.Serialize(record, _jsonOptions);
        await File.AppendAllTextAsync(HistoryFilePath, payload + Environment.NewLine);
    }

    public IReadOnlyList<HistoryRecord> LoadHistory(int maxEntries = 20)
    {
        if (!File.Exists(HistoryFilePath))
        {
            return [];
        }

        var records = new List<HistoryRecord>();
        foreach (var line in File.ReadLines(HistoryFilePath))
        {
            if (string.IsNullOrWhiteSpace(line))
            {
                continue;
            }

            try
            {
                var record = JsonSerializer.Deserialize<HistoryRecord>(line, _jsonOptions);
                if (record is not null)
                {
                    records.Add(record);
                }
            }
            catch
            {
                // Ignore corrupt history entries and keep the tool usable.
            }
        }

        return records
            .OrderByDescending(record => record.StartedAt)
            .Take(maxEntries)
            .ToList();
    }

    private static string ResolveRootDirectory()
    {
        var common = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.CommonApplicationData), "MagSupportTool");
        try
        {
            Directory.CreateDirectory(common);
            return common;
        }
        catch
        {
            var local = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "MagSupportTool");
            Directory.CreateDirectory(local);
            return local;
        }
    }
}
