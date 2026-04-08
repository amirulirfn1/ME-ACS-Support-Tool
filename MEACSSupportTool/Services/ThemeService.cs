using System.Windows;

namespace MEACSSupportTool.Services;

public static class ThemeService
{
    private const string LightSource = "Themes/Colors.xaml";
    private const string DarkSource  = "Themes/DarkColors.xaml";

    public static bool IsDark { get; private set; }

    public static void Apply(bool dark)
    {
        IsDark = dark;
        var merged = System.Windows.Application.Current.Resources.MergedDictionaries;

        var existing = merged.FirstOrDefault(d =>
            d.Source != null &&
            (d.Source.OriginalString.EndsWith("Colors.xaml", StringComparison.OrdinalIgnoreCase) ||
             d.Source.OriginalString.EndsWith("DarkColors.xaml", StringComparison.OrdinalIgnoreCase)));

        var next = new ResourceDictionary
        {
            Source = new Uri(dark ? DarkSource : LightSource, UriKind.Relative)
        };

        if (existing != null)
        {
            var index = merged.IndexOf(existing);
            merged[index] = next;
        }
        else
        {
            merged.Insert(0, next);
        }
    }
}
