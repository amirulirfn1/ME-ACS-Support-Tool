using System.Globalization;
using System.Windows;
using System.Windows.Data;

namespace MagDbPatcher.Converters;

/// <summary>
/// Collapses an element when the bound string is null or empty.
/// Pass ConverterParameter="Invert" to show when empty instead.
/// </summary>
[ValueConversion(typeof(string), typeof(Visibility))]
public sealed class NullOrEmptyToVisibilityConverter : IValueConverter
{
    public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
    {
        var isEmpty = string.IsNullOrEmpty(value as string);
        var invert = string.Equals(parameter as string, "Invert", StringComparison.OrdinalIgnoreCase);
        return (isEmpty ^ invert) ? Visibility.Collapsed : Visibility.Visible;
    }

    public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        => throw new NotSupportedException();
}
