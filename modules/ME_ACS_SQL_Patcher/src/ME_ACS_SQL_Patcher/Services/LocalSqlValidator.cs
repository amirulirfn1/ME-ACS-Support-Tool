namespace MagDbPatcher.Services;

public static class LocalSqlValidator
{
    public static bool IsLocalServer(string server)
    {
        if (string.IsNullOrWhiteSpace(server))
            return false;

        var s = server.Trim();

        if (s.Equals(".", StringComparison.OrdinalIgnoreCase) ||
            s.Equals("(local)", StringComparison.OrdinalIgnoreCase) ||
            s.Equals("localhost", StringComparison.OrdinalIgnoreCase) ||
            s.Equals("127.0.0.1", StringComparison.OrdinalIgnoreCase) ||
            s.Equals("::1", StringComparison.OrdinalIgnoreCase))
        {
            return true;
        }

        if (s.StartsWith(".\\", StringComparison.OrdinalIgnoreCase) ||
            s.StartsWith("localhost\\", StringComparison.OrdinalIgnoreCase))
        {
            return true;
        }

        if (s.StartsWith("(localdb)\\", StringComparison.OrdinalIgnoreCase))
        {
            return true;
        }

        var machineName = Environment.MachineName;
        if (s.Equals(machineName, StringComparison.OrdinalIgnoreCase) ||
            s.StartsWith(machineName + "\\", StringComparison.OrdinalIgnoreCase))
        {
            return true;
        }

        return false;
    }
}
