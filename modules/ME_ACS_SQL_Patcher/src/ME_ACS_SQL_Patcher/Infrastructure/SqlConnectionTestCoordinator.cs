using MagDbPatcher.Models;
using MagDbPatcher.ViewModels;

namespace MagDbPatcher.Infrastructure;

public sealed class SqlConnectionTestCoordinator
{
    private string _lastSuccessfulSignature = string.Empty;

    public bool IsConnectionTestPassed { get; private set; }

    public void Reset()
    {
        IsConnectionTestPassed = false;
        _lastSuccessfulSignature = string.Empty;
    }

    public void InvalidateIfSettingsChanged(string currentSignature)
    {
        if (!string.Equals(currentSignature, _lastSuccessfulSignature, StringComparison.Ordinal))
            IsConnectionTestPassed = false;
    }

    public SqlConnectionTestFeedback CreateMissingServerFeedback()
        => new(false, "Enter a SQL Server value.", SqlTestMessageTone.Error);

    public SqlConnectionTestFeedback CreateNonLocalServerFeedback()
        => new(false, "Only local SQL Server instances are allowed.", SqlTestMessageTone.Error);

    public SqlConnectionTestFeedback CreateTestingFeedback()
        => new(false, "Testing connection...", SqlTestMessageTone.Neutral);

    public SqlConnectionTestFeedback RegisterSuccess(SqlConnectionSettings settings)
    {
        IsConnectionTestPassed = true;
        _lastSuccessfulSignature = BuildSignature(settings);
        return new SqlConnectionTestFeedback(
            true,
            "Connection successful.",
            SqlTestMessageTone.Success,
            new NotificationState(NotificationLevel.Success, "SQL connection successful."));
    }

    public SqlConnectionTestFeedback RegisterFailure(string message, string bannerMessage)
    {
        IsConnectionTestPassed = false;
        return new SqlConnectionTestFeedback(
            false,
            message,
            SqlTestMessageTone.Error,
            new NotificationState(NotificationLevel.Error, bannerMessage));
    }

    public bool MatchesLastSuccessfulSettings(SqlConnectionSettings settings)
        => IsConnectionTestPassed && string.Equals(_lastSuccessfulSignature, BuildSignature(settings), StringComparison.Ordinal);

    public static string BuildSignature(SqlConnectionSettings settings)
        => $"{settings.Server}|{settings.AuthMode}|{settings.Username}|{settings.Password}";
}
