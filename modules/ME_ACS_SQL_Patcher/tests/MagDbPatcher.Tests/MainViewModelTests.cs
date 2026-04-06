using MagDbPatcher.Infrastructure;
using MagDbPatcher.ViewModels;
using Xunit;

namespace MagDbPatcher.Tests;

public class MainViewModelTests
{
    [Fact]
    public void SetValidationIssues_ReplacesCollection()
    {
        var vm = new MainViewModel();

        vm.SetValidationIssues(new[]
        {
            new ValidationIssue { Field = "A", Message = "1" },
            new ValidationIssue { Field = "B", Message = "2" }
        });

        Assert.Equal(2, vm.ValidationIssues.Count);
        Assert.Equal("A", vm.ValidationIssues[0].Field);

        vm.SetValidationIssues(new[]
        {
            new ValidationIssue { Field = "C", Message = "3" }
        });

        Assert.Single(vm.ValidationIssues);
        Assert.Equal("C", vm.ValidationIssues[0].Field);
    }

    [Fact]
    public void InlineNotificationService_UpdatesViewModelState()
    {
        var vm = new MainViewModel();
        var notifications = new InlineNotificationService(vm);

        notifications.ShowError("err");
        Assert.Equal("err", vm.NotificationMessage);
        Assert.Equal(NotificationLevel.Error, vm.NotificationLevel);

        notifications.Clear();
        Assert.Equal(string.Empty, vm.NotificationMessage);
        Assert.Equal(NotificationLevel.None, vm.NotificationLevel);
    }
}
