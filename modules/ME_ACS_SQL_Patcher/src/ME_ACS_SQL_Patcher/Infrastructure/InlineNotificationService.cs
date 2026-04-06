using MagDbPatcher.ViewModels;

namespace MagDbPatcher.Infrastructure;

public class InlineNotificationService : INotificationService
{
    private readonly MainViewModel _vm;

    public InlineNotificationService(MainViewModel vm)
    {
        _vm = vm;
    }

    public void ShowStatus(string message)
    {
        _vm.NotificationMessage = message;
        _vm.NotificationLevel = NotificationLevel.Info;
    }

    public void ShowSuccess(string message)
    {
        _vm.NotificationMessage = message;
        _vm.NotificationLevel = NotificationLevel.Success;
    }

    public void ShowError(string message)
    {
        _vm.NotificationMessage = message;
        _vm.NotificationLevel = NotificationLevel.Error;
    }

    public void Clear()
    {
        _vm.NotificationMessage = string.Empty;
        _vm.NotificationLevel = NotificationLevel.None;
    }
}
