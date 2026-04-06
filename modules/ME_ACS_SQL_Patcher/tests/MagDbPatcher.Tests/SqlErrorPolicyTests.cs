using MagDbPatcher.Services;
using Xunit;

namespace MagDbPatcher.Tests;

public class SqlErrorPolicyTests
{
    [Theory]
    [InlineData(823)]
    [InlineData(824)]
    [InlineData(825)]
    public void IsCorruptionIoError_TrueForIoCorruptionErrors(int errorNumber)
    {
        Assert.True(SqlErrorPolicy.IsCorruptionIoError(errorNumber));
    }

    [Theory]
    [InlineData(1913)]
    [InlineData(2714)]
    [InlineData(15010)]
    public void IsCorruptionIoError_FalseForNonCorruptionErrors(int errorNumber)
    {
        Assert.False(SqlErrorPolicy.IsCorruptionIoError(errorNumber));
    }
}

