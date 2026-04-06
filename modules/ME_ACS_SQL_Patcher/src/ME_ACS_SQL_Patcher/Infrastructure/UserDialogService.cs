using System.Windows;

namespace MagDbPatcher.Infrastructure;

public class UserDialogService : IUserDialogService
{
    public void ShowInfo(string message, string title) =>
        MessageBox.Show(message, title, MessageBoxButton.OK, MessageBoxImage.Information);

    public void ShowWarning(string message, string title) =>
        MessageBox.Show(message, title, MessageBoxButton.OK, MessageBoxImage.Warning);

    public void ShowError(string message, string title) =>
        MessageBox.Show(message, title, MessageBoxButton.OK, MessageBoxImage.Error);

    public bool Confirm(string message, string title, bool useYesNo = false)
    {
        var owner = Application.Current?.Windows.OfType<Window>().FirstOrDefault(window => window.IsActive)
            ?? Application.Current?.MainWindow;

        var dialog = new ConfirmDialogWindow(
            title,
            message,
            primaryButtonText: useYesNo ? "Yes" : "Continue",
            secondaryButtonText: useYesNo ? "No" : "Cancel")
        {
            Owner = owner
        };

        return dialog.ShowDialog() == true;
    }
}
