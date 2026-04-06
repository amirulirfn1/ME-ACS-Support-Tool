using System.Collections.ObjectModel;

namespace MagDbPatcher.ViewModels;

public sealed class AdminToolsViewModel : BindableBase
{
    private bool _isVisible;

    public bool IsVisible
    {
        get => _isVisible;
        set => SetProperty(ref _isVisible, value);
    }

    public ObservableCollection<VersionDisplayItem> Versions { get; } = new();
    public ObservableCollection<PatchDisplayItem> Patches { get; } = new();
}
