using MagDbPatcher.Services;
using Xunit;

namespace MagDbPatcher.Tests;

public class SqlScriptUtilsTests
{
    [Fact]
    public void StripStandaloneUseStatements_RemovesStandaloneUseLines()
    {
        var script = "USE [master];\nSELECT 1;\n  USE MyDb  \nSELECT 2;";
        var stripped = SqlScriptUtils.StripStandaloneUseStatements(script);

        Assert.DoesNotContain("USE [master]", stripped, StringComparison.OrdinalIgnoreCase);
        Assert.DoesNotContain("USE MyDb", stripped, StringComparison.OrdinalIgnoreCase);
        Assert.Contains("SELECT 1", stripped);
        Assert.Contains("SELECT 2", stripped);
    }

    [Fact]
    public void SplitOnGoBatches_SplitsOnGoLines()
    {
        var script = "SELECT 1;\nGO\nSELECT 2;\n  go  \nSELECT 3;";
        var batches = SqlScriptUtils.SplitOnGoBatches(script);

        Assert.True(batches.Count >= 3);
        Assert.Contains(batches, b => b.Contains("SELECT 1", StringComparison.OrdinalIgnoreCase));
        Assert.Contains(batches, b => b.Contains("SELECT 2", StringComparison.OrdinalIgnoreCase));
        Assert.Contains(batches, b => b.Contains("SELECT 3", StringComparison.OrdinalIgnoreCase));
    }

    [Fact]
    public void SplitOnGoBatches_DoesNotSplitGoInsideStringLiteral()
    {
        var script = "SELECT 'GO';\nGO\nSELECT 2;";
        var batches = SqlScriptUtils.SplitOnGoBatches(script);

        Assert.Equal(2, batches.Count(b => !string.IsNullOrWhiteSpace(b)));
        Assert.Contains("SELECT 'GO';", batches[0], StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    public void SplitOnGoBatches_DoesNotSplitGoInsideComments()
    {
        var script = "-- GO\nSELECT 1;\n/*\nGO\n*/\nGO\nSELECT 2;";
        var batches = SqlScriptUtils.SplitOnGoBatches(script);

        Assert.Equal(2, batches.Count(b => !string.IsNullOrWhiteSpace(b)));
        Assert.Contains("SELECT 1", batches[0], StringComparison.OrdinalIgnoreCase);
        Assert.Contains("SELECT 2", batches[1], StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    public void SplitOnGoBatches_HandlesMixedLineEndings()
    {
        var script = "SELECT 1;\r\nGO\rSELECT 2;\nGO\nSELECT 3;";
        var batches = SqlScriptUtils.SplitOnGoBatches(script);

        Assert.Equal(3, batches.Count(b => !string.IsNullOrWhiteSpace(b)));
    }

    [Fact]
    public void RewriteKnownLoginDefaultDb_RewritesLogindbAssignmentsOnly()
    {
        var script = """
IF NOT EXISTS (select * from master.dbo.syslogins where loginname = N'seserver')
BEGIN
    declare @logindb nvarchar(132), @loginlang nvarchar(132) select @logindb = N'soyaletegra', @loginlang = N'us_english'
    if @logindb is null or not exists (select * from master.dbo.sysdatabases where name = @logindb)
        select @logindb = N'soyaletegra'
    exec sp_addlogin N'seserver', '11201SEacs', @logindb, @loginlang
END

INSERT [dbo].[messages] ([message_id], [message_desc1]) VALUES (1, N'SoyalEtegra Access Control System')
""";

        var rewritten = SqlScriptUtils.RewriteKnownLoginDefaultDb(script);

        Assert.Contains("@logindb = DB_NAME()", rewritten, StringComparison.OrdinalIgnoreCase);
        Assert.DoesNotContain("@logindb = N'soyaletegra'", rewritten, StringComparison.OrdinalIgnoreCase);
        Assert.DoesNotContain("@logindb = 'soyaletegra'", rewritten, StringComparison.OrdinalIgnoreCase);
        Assert.Contains("SoyalEtegra Access Control System", rewritten, StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    public void RewriteKnownLoginDefaultDb_NoSpAddlogin_NoChange()
    {
        var script = "SELECT '@logindb = N\\'soyaletegra\\'';";
        var rewritten = SqlScriptUtils.RewriteKnownLoginDefaultDb(script);
        Assert.Equal(script, rewritten);
    }
}
