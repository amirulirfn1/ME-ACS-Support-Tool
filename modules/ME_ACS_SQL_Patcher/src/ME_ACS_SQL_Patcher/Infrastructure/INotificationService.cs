namespace MagDbPatcher.Infrastructure;

public interface INotificationService
{
    void ShowStatus(string message);
    void ShowSuccess(string message);
    void ShowError(string message);
    void Clear();
}
