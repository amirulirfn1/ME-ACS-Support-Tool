namespace MEACSSupportTool.Models;

public sealed class SqlTarget
{
    public required string DataSource { get; init; }

    public bool DatabaseExists { get; init; }
}
