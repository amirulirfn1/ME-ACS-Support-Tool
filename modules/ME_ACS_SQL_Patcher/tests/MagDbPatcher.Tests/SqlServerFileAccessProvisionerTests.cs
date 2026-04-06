using MagDbPatcher.Services;
using Xunit;

namespace MagDbPatcher.Tests;

public class SqlServerFileAccessProvisionerTests
{
    [Fact]
    public void BuildCandidateIdentities_IncludesNamedInstanceServiceIdentity()
    {
        var identities = SqlServerFileAccessProvisioner.BuildCandidateIdentities(@".\MAGSQL");

        Assert.Contains(@"NT AUTHORITY\NETWORK SERVICE", identities);
        Assert.Contains(@"NT SERVICE\MSSQL$MAGSQL", identities);
    }

    [Fact]
    public void BuildCandidateIdentities_SkipsLocalDbServiceIdentity()
    {
        var identities = SqlServerFileAccessProvisioner.BuildCandidateIdentities(@"(localdb)\MSSQLLocalDB");

        Assert.Contains(@"NT AUTHORITY\NETWORK SERVICE", identities);
        Assert.DoesNotContain(identities, value => value.StartsWith(@"NT SERVICE\", StringComparison.OrdinalIgnoreCase));
    }
}
