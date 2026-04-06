using System.Collections.ObjectModel;
using System.Diagnostics;
using System.ComponentModel;
using System.IO;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media.Animation;
using MagDbPatcher.Infrastructure;
using MagDbPatcher.Models;
using MagDbPatcher.Services;
using MagDbPatcher.ViewModels;
using MagDbPatcher.Workflows;
using Microsoft.Win32;

namespace MagDbPatcher;

public partial class AdminWindow : Window
{
    private IVersionService _versionService;
    private readonly Func<Task>? _onDataChanged;
    private readonly Func<string> _getCurrentPatchesFolder;
    private readonly Func<string, Task>? _setPatchesFolderAsync;
    private readonly Func<Task<string>>? _resetPatchesFolderAsync;
    private readonly Func<Task>? _persistSettingsAsync;
    private readonly Func<IVersionService?>? _getVersionService;

    private readonly IAdminCatalogOrchestrator _catalogOrchestrator;
    private readonly AdminUiStateController _uiStateController = new();
    private readonly AdminVersionChainFormatter _versionChainFormatter = new();
    private readonly IUserDialogService _dialogs = new UserDialogService();

    private readonly ObservableCollection<VersionDisplayItem> _versions = new();
    private readonly ObservableCollection<PatchDisplayItem> _patches = new();
    private readonly ObservableCollection<string> _scriptsForVersion = new();
    private readonly ObservableCollection<VersionDisplayItem> _libraryVersions = new();
    private readonly ObservableCollection<string> _libraryScripts = new();
    private readonly ObservableCollection<StagedPatchLinkDisplay> _stagedLinks = new();

    private readonly List<PatchLinkMutation> _stagedLinkMutations = new();
    private readonly ObservableCollection<string> _editPatchScripts = new();
    private PatchCatalogSnapshot? _librarySnapshot;
    private bool _isRefreshing;
    private bool _isAddingNewVersion;
    private bool _isAddingNewPatch;
    private bool _isLoadingForm;
    private bool _isVersionFormDirty;
    private bool _isPatchFormDirty;
    private bool _handlingTabSwitch;
    private int _previousTabIndex;
    private PatchCatalogDescriptor? _activePatchCatalog;

    public AdminWindow(
        IVersionService versionService,
        Func<Task>? onDataChanged = null,
        Func<string>? getCurrentPatchesFolder = null,
        Func<string, Task>? setPatchesFolderAsync = null,
        Func<Task<string>>? resetPatchesFolderAsync = null,
        Func<Task>? persistSettingsAsync = null,
        Func<IVersionService?>? getVersionService = null,
        IAdminCatalogOrchestrator? catalogOrchestrator = null)
    {
        _versionService = versionService;
        _onDataChanged = onDataChanged;
        _getCurrentPatchesFolder = getCurrentPatchesFolder ?? (() => versionService.GetPatchesFolder());
        _setPatchesFolderAsync = setPatchesFolderAsync;
        _resetPatchesFolderAsync = resetPatchesFolderAsync;
        _persistSettingsAsync = persistSettingsAsync;
        _getVersionService = getVersionService;
        _catalogOrchestrator = catalogOrchestrator ?? new AdminCatalogOrchestrator();

        InitializeComponent();
        Title = $"Admin Tools - {AppMetadata.DisplayVersion}";
        txtBuildVersion.Text = BuildHeaderVersionText();

        lstVersions.ItemsSource = _versions;
        lstPatches.ItemsSource = _patches;
        lstScripts.ItemsSource = _scriptsForVersion;
        lstPatchScripts.ItemsSource = _editPatchScripts;
        lstLibraryVersions.ItemsSource = _libraryVersions;
        lstLibraryScripts.ItemsSource = _libraryScripts;
        lstLibraryLinks.ItemsSource = _stagedLinks;

        Loaded += AdminWindow_Loaded;
    }

    private async void AdminWindow_Loaded(object sender, RoutedEventArgs e)
    {
        txtActivePatchesFolder.Text = _getCurrentPatchesFolder();
        await RefreshAdminDataAsync();
        await ScanCatalogAsync();
    }

    public async Task RefreshAdminDataAsync()
    {
        if (_isRefreshing)
            return;

        _isRefreshing = true;
        try
        {
            await _versionService.LoadVersionsAsync();

            var allVersions = _versionService.GetAllVersions();
            var allPatches = _versionService.GetAllPatches();

            var selectedVersionId = (lstVersions.SelectedItem as VersionDisplayItem)?.Id;
            var selectedPatchKey = GetSelectedPatchKey();

            _versions.Clear();
            foreach (var version in allVersions)
            {
                _versions.Add(new VersionDisplayItem
                {
                    Id = version.Id,
                    Name = version.Name,
                    UpgradesTo = version.UpgradesTo,
                    ScriptCount = _versionService.GetScriptCount(version.Id)
                });
            }

            _patches.Clear();
            foreach (var patch in allPatches
                         .OrderBy(p => p.From, StringComparer.OrdinalIgnoreCase)
                         .ThenBy(p => p.To, StringComparer.OrdinalIgnoreCase))
            {
                _patches.Add(new PatchDisplayItem
                {
                    From = patch.From,
                    To = patch.To,
                    ScriptCount = patch.Scripts.Count,
                    IsAutoGenerated = patch.AutoGenerated
                });
            }

            lstVersions.SelectedItem = _versions.FirstOrDefault(v =>
                string.Equals(v.Id, selectedVersionId, StringComparison.OrdinalIgnoreCase));
            if (lstVersions.SelectedItem == null && _versions.Count > 0)
                lstVersions.SelectedIndex = 0;

            lstPatches.SelectedItem = _patches.FirstOrDefault(p =>
                string.Equals($"{p.From}->{p.To}", selectedPatchKey, StringComparison.OrdinalIgnoreCase));
            if (lstPatches.SelectedItem == null && _patches.Count > 0)
                lstPatches.SelectedIndex = 0;

            RefreshVersionScripts();
            RefreshPatchScripts();
            UpdateButtonsState();
            RebuildChainVisualization();
            RefreshPatchCatalogStatus();
        }
        finally
        {
            _isRefreshing = false;
        }
    }

    private void RefreshPatchCatalogStatus()
    {
        _activePatchCatalog = PatchCatalogDescriptorBuilder.FromVersionService(_versionService);
        txtBuildVersion.Text = BuildHeaderVersionText();
        txtFolderStatus.Text = $"Active catalog: {_activePatchCatalog.Label}";
    }

    private static string BuildHeaderVersionText()
    {
        if (string.IsNullOrWhiteSpace(AppMetadata.InstalledPatchCatalogLabel))
            return AppMetadata.BuildLabel;

        return $"{AppMetadata.BuildLabel}{Environment.NewLine}Bundled {AppMetadata.InstalledPatchCatalogLabel}";
    }

    private void RebuildChainVisualization()
    {
        txtVersionChain.Text = _versionChainFormatter.Format(_versionService.GetAllVersions());
    }

    private string? GetSelectedPatchKey()
    {
        if (lstPatches.SelectedItem is not PatchDisplayItem item)
            return null;

        return $"{item.From}->{item.To}";
    }

    private async Task OnMutationCompletedAsync()
    {
        await RefreshAdminDataAsync();

        if (_onDataChanged != null)
            await _onDataChanged.Invoke();
    }
}
