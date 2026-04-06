using MagDbPatcher.Infrastructure;
using Xunit;

namespace MagDbPatcher.Tests;

public class SingleInstanceCoordinatorTests
{
    [Fact]
    public void BuildInstanceKey_ReturnsStableValue_ForEquivalentPaths()
    {
        var pathA = @"C:\Support\ME_ACS_SQL_Patcher\";
        var pathB = @"c:\support\ME_ACS_SQL_Patcher";

        var keyA = SingleInstanceCoordinator.BuildInstanceKey(pathA);
        var keyB = SingleInstanceCoordinator.BuildInstanceKey(pathB);

        Assert.Equal(keyA, keyB);
        Assert.Equal(32, keyA.Length);
    }

    [Fact]
    public void BuildInstanceKey_ReturnsDifferentValue_ForDifferentRoots()
    {
        var keyA = SingleInstanceCoordinator.BuildInstanceKey(@"C:\Support\ME_ACS_SQL_Patcher");
        var keyB = SingleInstanceCoordinator.BuildInstanceKey(@"D:\Support\ME_ACS_SQL_Patcher");

        Assert.NotEqual(keyA, keyB);
    }

    [Fact]
    public async Task TrySignalPrimaryInstanceAsync_ReachesListeningPrimaryInstance()
    {
        var root = CreateTempDir();
        try
        {
            var activationCount = 0;
            using var primary = new SingleInstanceCoordinator(
                TestAppPaths.Create(root),
                () =>
                {
                    Interlocked.Increment(ref activationCount);
                    return Task.CompletedTask;
                });

            Assert.True(primary.IsPrimaryInstance);
            primary.StartListening();

            var signaled = await primary.TrySignalPrimaryInstanceAsync(TimeSpan.FromSeconds(2));

            Assert.True(signaled);
            await WaitForAsync(() => Volatile.Read(ref activationCount) == 1, TimeSpan.FromSeconds(2));
        }
        finally
        {
            TryDelete(root);
        }
    }

    private static async Task WaitForAsync(Func<bool> condition, TimeSpan timeout)
    {
        var started = DateTime.UtcNow;
        while (DateTime.UtcNow - started < timeout)
        {
            if (condition())
                return;

            await Task.Delay(50);
        }

        Assert.True(condition(), "Timed out waiting for the single-instance activation signal.");
    }

    private static string CreateTempDir()
    {
        var dir = Path.Combine(Path.GetTempPath(), "MagDbPatcherTests_" + Guid.NewGuid().ToString("N"));
        Directory.CreateDirectory(dir);
        return dir;
    }

    private static void TryDelete(string path)
    {
        try
        {
            if (Directory.Exists(path))
                Directory.Delete(path, recursive: true);
        }
        catch
        {
        }
    }
}
