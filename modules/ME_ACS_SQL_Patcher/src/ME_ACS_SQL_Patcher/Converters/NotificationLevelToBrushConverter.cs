using System.Globalization;
using System.Windows;
using System.Windows.Data;
using System.Windows.Media;
using MagDbPatcher.Infrastructure;
using MagDbPatcher.ViewModels;

namespace MagDbPatcher.Converters;

/// <summary>
/// Converts a <see cref="NotificationLevel"/> to the matching semantic brush resource.
/// Replaces the switch/FindResource pattern repeated throughout code-behind.
/// </summary>
[ValueConversion(typeof(NotificationLevel), typeof(Brush))]
public sealed class NotificationLevelToBrushConverter : IValueConverter
{
    public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
    {
        if (value is not NotificationLevel level)
            return DependencyProperty.UnsetValue;

        var key = level switch
        {
            NotificationLevel.Success => "Success",
            NotificationLevel.Error   => "Error",
            _                         => "Info"
        };

        return Application.Current.FindResource(key) ?? DependencyProperty.UnsetValue;
    }

    public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        => throw new NotSupportedException();
}
