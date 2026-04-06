using MagDbPatcher.Models;
using Microsoft.Data.SqlClient;

namespace MagDbPatcher.Services;

public static class SqlConnectionBuilder
{
    public static string BuildMasterConnectionString(SqlConnectionSettings settings)
        => BuildConnectionString(settings, "master");

    public static string BuildDatabaseConnectionString(SqlConnectionSettings settings, string databaseName)
        => BuildConnectionString(settings, databaseName);

    private static string BuildConnectionString(SqlConnectionSettings settings, string databaseName)
    {
        if (settings == null) throw new ArgumentNullException(nameof(settings));

        var builder = new SqlConnectionStringBuilder
        {
            DataSource = settings.Server,
            InitialCatalog = databaseName,
            TrustServerCertificate = true
        };

        if (settings.AuthMode == SqlAuthMode.SqlLogin)
        {
            builder.IntegratedSecurity = false;
            builder.UserID = settings.Username ?? "";
            builder.Password = settings.Password ?? "";
        }
        else
        {
            builder.IntegratedSecurity = true;
        }

        return builder.ConnectionString;
    }
}
