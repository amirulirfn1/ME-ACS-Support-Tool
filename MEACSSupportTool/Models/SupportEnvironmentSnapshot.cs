namespace MEACSSupportTool.Models;

public sealed class SupportEnvironmentSnapshot
{
    public required string MachineName { get; init; }

    public required string CurrentUser { get; init; }

    public bool IsAdministrator { get; init; }

    public bool HasInternetAccess { get; init; }

    public bool RabbitMqInstalled { get; init; }

    public bool RabbitMqRunning { get; init; }

    public bool SsmsInstalled { get; init; }

    public bool SqlReachable { get; init; }

    public string? SqlDataSource { get; init; }

    public bool MagEtegraDatabaseExists { get; init; }

    public string? SqlError { get; init; }
}
