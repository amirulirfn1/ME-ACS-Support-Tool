using System.ComponentModel;
using System.Globalization;
using System.Windows.Data;

namespace MagDbPatcher.Converters;

/// <summary>
/// Renders an enum value as its <see cref="DescriptionAttribute"/> text, or falls back to
/// the enum member name with camel-case word splitting (e.g. WarnAndContinue → "Warn And Continue").
/// </summary>
[ValueConversion(typeof(Enum), typeof(string))]
public sealed class EnumToStringConverter : IValueConverter
{
    public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
    {
        if (value is not Enum e)
            return string.Empty;

        var field = e.GetType().GetField(e.ToString());
        if (field?.GetCustomAttributes(typeof(DescriptionAttribute), false)
                  .FirstOrDefault() is DescriptionAttribute desc)
            return desc.Description;

        return SplitCamelCase(e.ToString());
    }

    public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        => throw new NotSupportedException();

    private static string SplitCamelCase(string input)
        => System.Text.RegularExpressions.Regex.Replace(input, "(?<=[a-z])(?=[A-Z])", " ");
}
