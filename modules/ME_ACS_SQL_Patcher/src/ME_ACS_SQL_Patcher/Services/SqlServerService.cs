using System.IO;
using System.Text.RegularExpressions;
using MagDbPatcher.Models;
using Microsoft.Data.SqlClient;

namespace MagDbPatcher.Services;

public class SqlServerService
{
    private readonly SqlConnectionSettings _settings;
    private readonly string _masterConnectionString;
    private readonly IProgress<string>? _progress;
    private readonly IProgress<SqlBatchWarning>? _warnings;
    private readonly PatchErrorMode _errorMode;

    public SqlServerService(
        SqlConnectionSettings settings,
        IProgress<string>? progress = null,
        PatchExecutionOptions? executionOptions = null)
        : this(settings, progress, warnings: null, executionOptions)
    {
    }

    public SqlServerService(
        SqlConnectionSettings settings,
        IProgress<string>? progress,
        IProgress<SqlBatchWarning>? warnings,
        PatchExecutionOptions? executionOptions = null)
    {
        if (settings == null) throw new ArgumentNullException(nameof(settings));
        if (string.IsNullOrWhiteSpace(settings.Server))
            throw new ArgumentException("SQL Server name is required.", nameof(settings));

        _settings = settings;
        _masterConnectionString = SqlConnectionBuilder.BuildMasterConnectionString(settings);
        _progress = progress;
        _warnings = warnings;
        _errorMode = executionOptions?.ErrorMode ?? PatchErrorMode.WarnAndContinue;
    }

    public SqlServerService(
        string serverName,
        IProgress<string>? progress = null,
        PatchExecutionOptions? executionOptions = null)
        : this(serverName, progress, warnings: null, executionOptions)
    {
    }

    public SqlServerService(
        string serverName,
        IProgress<string>? progress,
        IProgress<SqlBatchWarning>? warnings,
        PatchExecutionOptions? executionOptions = null)
        : this(new SqlConnectionSettings { Server = serverName, AuthMode = SqlAuthMode.Windows }, progress, warnings, executionOptions)
    {
    }

    protected void EmitProgress(string message) => _progress?.Report(message);

    protected void EmitWarning(SqlBatchWarning warning) => _warnings?.Report(warning);

    public virtual void EnsureTempFolderAccess(string tempFolder)
        => SqlServerFileAccessProvisioner.EnsureSqlServiceAccess(_settings.Server, tempFolder);

    public virtual async Task<bool> TestConnectionAsync(CancellationToken cancellationToken = default)
    {
        try
        {
            using var connection = new SqlConnection(_masterConnectionString);
            await connection.OpenAsync(cancellationToken);
            return true;
        }
        catch
        {
            return false;
        }
    }

    public virtual async Task RestoreDatabaseAsync(string bakFilePath, string databaseName, CancellationToken cancellationToken = default)
    {
        EmitProgress($"Restoring backup to database '{databaseName}'...");

        using var connection = new SqlConnection(_masterConnectionString);
        await connection.OpenAsync(cancellationToken);

        List<BackupFileEntry> fileList;
        try
        {
            fileList = await GetBackupFileListAsync(connection, bakFilePath, cancellationToken);
        }
        catch (SqlException ex) when (IsBackupAccessFailure(ex))
        {
            throw new InvalidOperationException(BuildBackupAccessFailureMessage(bakFilePath, ex.Message), ex);
        }

        var dataLogical = fileList.Where(f => f.Type == "D").OrderBy(f => f.FileId).ToList();
        var logLogical = fileList.Where(f => f.Type == "L").OrderBy(f => f.FileId).ToList();

        if (dataLogical.Count == 0 || logLogical.Count == 0)
        {
            throw new InvalidOperationException(BuildBackupAccessFailureMessage(
                bakFilePath,
                "SQL Server could not read the backup file layout (RESTORE FILELISTONLY returned no data/log entries)."));
        }

        var dataPath = await GetDefaultDataPathAsync(connection, cancellationToken);
        var logPath = await GetDefaultLogPathAsync(connection, cancellationToken);

        var moveClauses = new List<string>();
        for (var i = 0; i < dataLogical.Count; i++)
        {
            var logical = dataLogical[i].LogicalName;
            var fileName = i == 0 ? $"{databaseName}.mdf" : $"{databaseName}_{i + 1}.ndf";
            var physical = Path.Combine(dataPath, fileName);
            moveClauses.Add($"MOVE {ToSqlStringLiteral(logical)} TO {ToSqlStringLiteral(physical)}");
        }

        for (var i = 0; i < logLogical.Count; i++)
        {
            var logical = logLogical[i].LogicalName;
            var fileName = i == 0 ? $"{databaseName}_log.ldf" : $"{databaseName}_log_{i + 1}.ldf";
            var physical = Path.Combine(logPath, fileName);
            moveClauses.Add($"MOVE {ToSqlStringLiteral(logical)} TO {ToSqlStringLiteral(physical)}");
        }

        var movesSql = string.Join(", ", moveClauses);

        var restoreQuery = @"
DECLARE @db sysname = @dbName;
DECLARE @bak nvarchar(4000) = @bakPath;
DECLARE @moves nvarchar(max) = @movesSql;
DECLARE @sql nvarchar(max) =
    N'RESTORE DATABASE ' + QUOTENAME(@db) +
    N' FROM DISK = ' + QUOTENAME(@bak, '''') +
    N' WITH ' + @moves +
    N', REPLACE, STATS = 10';
EXEC(@sql);";

        using (var cmd = new SqlCommand(restoreQuery, connection))
        {
            cmd.CommandTimeout = 600;
            cmd.Parameters.AddWithValue("@dbName", databaseName);
            cmd.Parameters.AddWithValue("@bakPath", bakFilePath);
            cmd.Parameters.AddWithValue("@movesSql", movesSql);
            await cmd.ExecuteNonQueryAsync(cancellationToken);
        }

        EmitProgress($"Database '{databaseName}' restored successfully.");
    }

    public virtual async Task ExecuteScriptAsync(string databaseName, string scriptPath, CancellationToken cancellationToken = default)
    {
        EmitProgress($"Executing: {Path.GetFileName(scriptPath)}...");

        var script = await File.ReadAllTextAsync(scriptPath, cancellationToken);
        script = SqlScriptUtils.RewriteKnownLoginDefaultDb(script);
        script = SqlScriptUtils.StripStandaloneUseStatements(script);

        // After stripping standalone USE lines, disallow any remaining USE directives at start of a line.
        if (Regex.IsMatch(script, @"(?im)^\s*USE\s+"))
        {
            throw new InvalidOperationException($"Script contains unsupported USE statement(s): {Path.GetFileName(scriptPath)}");
        }

        var dbConnectionString = SqlConnectionBuilder.BuildDatabaseConnectionString(_settings, databaseName);
        using var connection = new SqlConnection(dbConnectionString);
        await connection.OpenAsync(cancellationToken);

        var batches = SqlScriptUtils.SplitOnGoBatches(script);
        for (var i = 0; i < batches.Count; i++)
        {
            cancellationToken.ThrowIfCancellationRequested();

            var batch = batches[i].Trim();
            if (string.IsNullOrWhiteSpace(batch)) continue;

            if (connection.State != System.Data.ConnectionState.Open)
            {
                throw new InvalidOperationException(
                    $"Connection to SQL Server is not open while executing {Path.GetFileName(scriptPath)} (batch {i + 1}/{batches.Count}). " +
                    "This usually means SQL Server terminated the session (e.g., service restart, database corruption, or connectivity loss).");
            }

            using var cmd = new SqlCommand(batch, connection);
            cmd.CommandTimeout = 300;

            try
            {
                await cmd.ExecuteNonQueryAsync(cancellationToken);
            }
            catch (SqlException ex)
            {
                var preview = batch.Length > 200 ? batch[..200] : batch;

                if (SqlErrorPolicy.IsCorruptionIoError(ex.Number))
                {
                    var hint =
                        "\nHint: This SQL error commonly indicates I/O or database corruption. Try restoring a known-good backup, and run DBCC CHECKDB on the restored database.";
                    throw new InvalidOperationException(
                        $"SQL error in {Path.GetFileName(scriptPath)} (batch {i + 1}/{batches.Count}, error {ex.Number}): {ex.Message}\nBatch preview:\n{preview}{hint}",
                        ex);
                }

                if (_errorMode == PatchErrorMode.FailFast)
                {
                    throw new InvalidOperationException(
                        $"SQL error in {Path.GetFileName(scriptPath)} (batch {i + 1}/{batches.Count}, error {ex.Number}): {ex.Message}\nBatch preview:\n{preview}",
                        ex);
                }

                var scriptName = Path.GetFileName(scriptPath);
                EmitProgress($"WARN: Ignored SQL error {ex.Number} in {scriptName} (batch {i + 1}/{batches.Count}): {ex.Message}");
                EmitWarning(new SqlBatchWarning(
                    scriptName,
                    i + 1,
                    batches.Count,
                    ex.Number,
                    ex.Message,
                    preview));

                continue;
            }
            catch (InvalidOperationException ex) when (connection.State != System.Data.ConnectionState.Open)
            {
                var preview = batch.Length > 200 ? batch[..200] : batch;
                throw new InvalidOperationException(
                    $"Connection to SQL Server was closed while executing {Path.GetFileName(scriptPath)} (batch {i + 1}/{batches.Count}). " +
                    "This usually means SQL Server aborted the session due to a fatal error (often 823/824/825) or the service restarted.\n" +
                    $"Batch preview:\n{preview}",
                    ex);
            }
        }

        EmitProgress($"Completed: {Path.GetFileName(scriptPath)}");
    }

    public virtual async Task BackupDatabaseAsync(string databaseName, string outputPath, CancellationToken cancellationToken = default)
    {
        EmitProgress($"Creating backup at '{outputPath}'...");

        using var connection = new SqlConnection(_masterConnectionString);
        await connection.OpenAsync(cancellationToken);

        var backupQuery = @"
DECLARE @db sysname = @dbName;
DECLARE @out nvarchar(4000) = @outPath;
DECLARE @sql nvarchar(max) =
    N'BACKUP DATABASE ' + QUOTENAME(@db) +
    N' TO DISK = ' + QUOTENAME(@out, '''') +
    N' WITH FORMAT, INIT, STATS = 10';
EXEC(@sql);";

        using var cmd = new SqlCommand(backupQuery, connection);
        cmd.CommandTimeout = 600;
        cmd.Parameters.AddWithValue("@dbName", databaseName);
        cmd.Parameters.AddWithValue("@outPath", outputPath);
        await cmd.ExecuteNonQueryAsync(cancellationToken);

        EmitProgress("Backup created successfully.");
    }

    public virtual async Task DropDatabaseAsync(string databaseName, CancellationToken cancellationToken = default)
    {
        EmitProgress("Cleaning up temporary database...");

        using var connection = new SqlConnection(_masterConnectionString);
        await connection.OpenAsync(cancellationToken);

        var dropQuery = @"
DECLARE @db sysname = @dbName;
DECLARE @sql nvarchar(max) =
    N'IF EXISTS (SELECT 1 FROM sys.databases WHERE name = ' + QUOTENAME(@db, '''') + N') ' +
    N'BEGIN ' +
    N'  ALTER DATABASE ' + QUOTENAME(@db) + N' SET SINGLE_USER WITH ROLLBACK IMMEDIATE; ' +
    N'  DROP DATABASE ' + QUOTENAME(@db) + N'; ' +
    N'END';
EXEC(@sql);";

        using var cmd = new SqlCommand(dropQuery, connection);
        cmd.CommandTimeout = 60;
        cmd.Parameters.AddWithValue("@dbName", databaseName);
        await cmd.ExecuteNonQueryAsync(cancellationToken);

        EmitProgress("Cleanup completed.");
    }

    private async Task<string> GetDefaultDataPathAsync(SqlConnection connection, CancellationToken cancellationToken)
    {
        var query = "SELECT SERVERPROPERTY('InstanceDefaultDataPath')";
        using var cmd = new SqlCommand(query, connection);
        var result = await cmd.ExecuteScalarAsync(cancellationToken);
        return result?.ToString() ?? @"C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA";
    }

    private async Task<string> GetDefaultLogPathAsync(SqlConnection connection, CancellationToken cancellationToken)
    {
        var query = "SELECT SERVERPROPERTY('InstanceDefaultLogPath')";
        using var cmd = new SqlCommand(query, connection);
        var result = await cmd.ExecuteScalarAsync(cancellationToken);
        return result?.ToString() ?? @"C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA";
    }

    private static string ToSqlStringLiteral(string value)
    {
        // N'...' to preserve Unicode. Escape single quotes.
        return "N'" + value.Replace("'", "''") + "'";
    }

    private async Task<List<BackupFileEntry>> GetBackupFileListAsync(SqlConnection connection, string bakFilePath, CancellationToken cancellationToken)
    {
        var query = @"
DECLARE @bak nvarchar(4000) = @bakPath;
DECLARE @sql nvarchar(max) = N'RESTORE FILELISTONLY FROM DISK = ' + QUOTENAME(@bak, '''');
EXEC(@sql);";

        using var cmd = new SqlCommand(query, connection);
        cmd.CommandTimeout = 300;
        cmd.Parameters.AddWithValue("@bakPath", bakFilePath);

        var entries = new List<BackupFileEntry>();
        using var reader = await cmd.ExecuteReaderAsync(cancellationToken);
        while (await reader.ReadAsync(cancellationToken))
        {
            var type = reader["Type"]?.ToString() ?? "";
            var logicalName = reader["LogicalName"]?.ToString() ?? "";

            var fileId = 0;
            try
            {
                var fileIdOrdinal = reader.GetOrdinal("FileId");
                if (fileIdOrdinal >= 0 && !reader.IsDBNull(fileIdOrdinal))
                    fileId = Convert.ToInt32(reader.GetValue(fileIdOrdinal));
            }
            catch
            {
                // Older/variant resultsets may not include FileId; keep default 0.
            }

            if (string.IsNullOrWhiteSpace(type) || string.IsNullOrWhiteSpace(logicalName))
                continue;

            entries.Add(new BackupFileEntry(fileId, logicalName, type));
        }

        return entries;
    }

    private static bool IsBackupAccessFailure(SqlException ex)
        => ex.Number == 3201 ||
           ex.Number == 3013 ||
           ex.Message.Contains("Access is denied", StringComparison.OrdinalIgnoreCase) ||
           ex.Message.Contains("Cannot open backup device", StringComparison.OrdinalIgnoreCase);

    private static string BuildBackupAccessFailureMessage(string bakFilePath, string detail)
        => $"SQL Server could not read the backup file needed for restore: {bakFilePath}{Environment.NewLine}" +
           "This is not a patch-script warning, so the run cannot continue yet." + Environment.NewLine +
           "Most common cause: the SQL Server service account does not have access to the patcher temp folder or the backup file location." + Environment.NewLine +
           "Try using a temp folder SQL Server can access, or rerun after the app grants SQL access to the temp workspace." + Environment.NewLine +
           $"SQL detail: {detail}";

    private readonly record struct BackupFileEntry(int FileId, string LogicalName, string Type);

    public virtual Task<List<string>> GetAvailableSqlServersAsync()
    {
        var servers = new List<string> { ".", "localhost", "(local)" };

        // Try common SQL Server instance names
        var instances = new[] { "SQLEXPRESS", "MSSQLSERVER", "SQL2022", "SQL2019" };
        foreach (var instance in instances)
        {
            servers.Add($".\\{instance}");
            servers.Add($"localhost\\{instance}");
        }

        return Task.FromResult(servers);
    }
}
