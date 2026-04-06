using System.Globalization;
using System.Windows.Data;

namespace MagDbPatcher.Converters;

/// <summary>
/// Negates a boolean binding — useful for IsEnabled/IsReadOnly toggling without code-behind.
/// </summary>
[ValueConversion(typeof(bool), typeof(bool))]
public sealed class InverseBoolConverter : IValueConverter
{
    public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        => value is bool b && !b;

    public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        => value is bool b && !b;
}
