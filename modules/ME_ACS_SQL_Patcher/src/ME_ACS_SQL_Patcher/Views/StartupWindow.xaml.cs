using System.Windows;
using MagDbPatcher.Infrastructure;

namespace MagDbPatcher;

public partial class StartupWindow : Window
{
    public StartupWindow()
    {
        InitializeComponent();
        txtBuildVersion.Text = AppMetadata.BuildLabel;
        UpdateStatus("Starting ME_ACS SQL Patcher...");
    }

    public void UpdateStatus(string message)
    {
        txtStatus.Text = message;
    }
}
