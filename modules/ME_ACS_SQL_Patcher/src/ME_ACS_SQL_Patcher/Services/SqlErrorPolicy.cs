namespace MagDbPatcher.Services;

internal static class SqlErrorPolicy
{
    internal static bool IsCorruptionIoError(int errorNumber) => errorNumber is 823 or 824 or 825;
}

