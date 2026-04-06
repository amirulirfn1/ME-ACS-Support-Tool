namespace MEACSSupportTool.Models;

public sealed class ToolkitModuleInfo
{
    public required string StatusText { get; init; }

    public required string LocationText { get; init; }

    public required string DetailText { get; init; }

    public string? BuildText { get; init; }

    public string? ModuleRootPath { get; init; }

    public string? ProjectPath { get; init; }

    public string? LaunchPath { get; init; }

    public bool CanOpenWorkspace { get; init; }

    public bool CanLaunch { get; init; }
}
