using System.Windows;

namespace MagDbPatcher.Infrastructure;

public partial class ConfirmDialogWindow : Window
{
    public ConfirmDialogWindow(
        string title,
        string message,
        string primaryButtonText,
        string secondaryButtonText)
    {
        InitializeComponent();

        Title = title;
        txtTitle.Text = title;
        txtMessage.Text = message;
        btnPrimary.Content = primaryButtonText;
        btnSecondary.Content = secondaryButtonText;

        Loaded += ConfirmDialogWindow_Loaded;
    }

    private void ConfirmDialogWindow_Loaded(object sender, RoutedEventArgs e)
    {
        var workArea = SystemParameters.WorkArea;
        MaxWidth = Math.Max(MinWidth, workArea.Width - 40);
        MaxHeight = Math.Max(MinHeight, workArea.Height - 40);

        if (Width > MaxWidth)
            Width = MaxWidth;

        if (Height > MaxHeight)
            Height = MaxHeight;
    }

    private void BtnPrimary_Click(object sender, RoutedEventArgs e)
    {
        DialogResult = true;
    }

    private void BtnSecondary_Click(object sender, RoutedEventArgs e)
    {
        DialogResult = false;
    }
}
