using System;
using System.Collections.Generic;
using MagDbPatcher.Infrastructure;
using MagDbPatcher.Models;
using MagDbPatcher.ViewModels;

namespace MagDbPatcher.Workflows;

public sealed class PatchRunRequest
{
    public string SourceBakPath { get; init; } = "";
    public string OutputBakPath { get; init; } = "";
    public string FromVersionId { get; init; } = "";
    public string ToVersionId { get; init; } = "";
    public string TempFolder { get; init; } = AppRuntimePaths.CreateDefault().TempFolder;
    public PatchExecutionOptions ExecutionOptions { get; init; } = new();
    public SqlConnectionSettings ConnectionSettings { get; init; } = new();
}

public sealed class PatchRunProgress
{
    public int Percent { get; init; }
    public string Message { get; init; } = "";
    public PatchFlowState FlowState { get; init; }
    public int CurrentScript { get; init; }
    public int TotalScripts { get; init; }
    public int WarningCount { get; init; }
}

public sealed class PatchRunResult
{
    public bool Success { get; init; }
    public bool Cancelled { get; init; }
    public string OutputPath { get; init; } = "";
    public string Summary { get; init; } = "";
    public string Diagnostics { get; init; } = "";
    public int WarningCount { get; init; }
    public int WarningThreshold { get; init; }
    public bool WarningThresholdExceeded { get; init; }
    public IReadOnlyList<SqlBatchWarning> Warnings { get; init; } = Array.Empty<SqlBatchWarning>();
    public IReadOnlyDictionary<int, int> WarningCountsBySqlError { get; init; } = new Dictionary<int, int>();
}

public sealed class PatchImportRequest
{
    public string ZipPath { get; init; } = "";
    public string TargetPatchesFolder { get; init; } = "";
}

public sealed class PatchImportResult
{
    public string BackupFolder { get; init; } = "";
    public string PackLabel { get; init; } = "";
    public string? ArchivedPackPath { get; init; }
}
