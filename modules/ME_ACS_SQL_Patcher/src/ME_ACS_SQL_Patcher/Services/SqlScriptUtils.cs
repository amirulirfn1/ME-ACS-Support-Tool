using System.Text;
using System.Text.RegularExpressions;

namespace MagDbPatcher.Services;

internal static class SqlScriptUtils
{
    private static readonly Regex StandaloneUseRegex =
        new(@"^\s*USE\s+(\[[^\]]+\]|\w+)\s*;?\s*$", RegexOptions.IgnoreCase | RegexOptions.Compiled);

    private static readonly Regex LoginDefaultDbRegex =
        new(@"(?im)(@logindb\s*=\s*)(N)?'(soyaletegra|magetegra)'", RegexOptions.Compiled);

    public static string StripStandaloneUseStatements(string script)
    {
        if (string.IsNullOrEmpty(script))
            return script;

        // Normalize line endings for stable processing.
        script = script.Replace("\r\n", "\n").Replace('\r', '\n');

        var lines = script.Split('\n');
        var kept = new List<string>(lines.Length);

        foreach (var line in lines)
        {
            if (StandaloneUseRegex.IsMatch(line))
                continue;
            kept.Add(line);
        }

        return string.Join("\n", kept);
    }

    public static string RewriteKnownLoginDefaultDb(string script)
    {
        if (string.IsNullOrEmpty(script))
            return script;

        // Cheap guard: only touch scripts that attempt to create a SQL login.
        if (script.IndexOf("sp_addlogin", StringComparison.OrdinalIgnoreCase) < 0)
            return script;

        return LoginDefaultDbRegex.Replace(script, "$1DB_NAME()");
    }

    public static List<string> SplitOnGoBatches(string script)
    {
        if (string.IsNullOrEmpty(script))
            return new List<string> { "" };

        var normalized = script.Replace("\r\n", "\n").Replace('\r', '\n');
        var batches = new List<string>();
        var current = new StringBuilder();

        var lineStart = 0;
        var inSingleQuote = false;
        var inBlockComment = false;

        for (var i = 0; i <= normalized.Length; i++)
        {
            var atEnd = i == normalized.Length;
            var c = atEnd ? '\n' : normalized[i];

            if (!atEnd)
            {
                if (inSingleQuote)
                {
                    if (c == '\'')
                    {
                        if (i + 1 < normalized.Length && normalized[i + 1] == '\'')
                        {
                            i++;
                        }
                        else
                        {
                            inSingleQuote = false;
                        }
                    }
                }
                else if (inBlockComment)
                {
                    if (c == '*' && i + 1 < normalized.Length && normalized[i + 1] == '/')
                    {
                        inBlockComment = false;
                        i++;
                    }
                }
                else
                {
                    if (c == '-' && i + 1 < normalized.Length && normalized[i + 1] == '-')
                    {
                        while (i < normalized.Length && normalized[i] != '\n')
                            i++;

                        c = i == normalized.Length ? '\n' : normalized[i];
                    }
                    else if (c == '/' && i + 1 < normalized.Length && normalized[i + 1] == '*')
                    {
                        inBlockComment = true;
                        i++;
                    }
                    else if (c == '\'')
                    {
                        inSingleQuote = true;
                    }
                }
            }

            if (c != '\n' && !atEnd)
                continue;

            var line = normalized.Substring(lineStart, i - lineStart);
            if (!inSingleQuote && !inBlockComment && IsGoSeparator(line))
            {
                batches.Add(current.ToString());
                current.Clear();
            }
            else
            {
                current.Append(line);
                if (!atEnd)
                    current.Append('\n');
            }

            lineStart = i + 1;
        }

        batches.Add(current.ToString());
        return batches;
    }

    private static bool IsGoSeparator(string line)
    {
        if (string.IsNullOrWhiteSpace(line))
            return false;

        return line.Trim().Equals("GO", StringComparison.OrdinalIgnoreCase);
    }
}
