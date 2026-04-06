using MagDbPatcher.Infrastructure;

namespace MagDbPatcher.Tests;

internal static class TestAppPaths
{
    public static AppRuntimePaths Create(string root)
        => new(
            root,
            userDataDirectory: Path.Combine(root, "user-data"),
            machineDataDirectory: Path.Combine(root, "machine-data"));
}
