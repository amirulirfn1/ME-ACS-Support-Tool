using System.Diagnostics;
using System.IO;
using System.Text.Json;
using MEACSSupportTool.Models;

namespace MEACSSupportTool.Services;

public sealed class ToolkitModuleService
{
    private const string SqlPatcherModuleFolder = "ME_ACS_SQL_Patcher";
    private const string SqlPatcherProjectRelativePath = @"src\ME_ACS_SQL_Patcher\ME_ACS_SQL_Patcher.csproj";
    private const string SqlPatcherExecutableName = "ME_ACS_SQL_Patcher.exe";
    private const string BundledModuleRelativePath = @"Modules\SqlPatcher\ME_ACS_SQL_Patcher.exe";
    private const string BundledManifestPath = "toolkit-manifest.json";
    private const string BundledPatchCatalogPath = "patch-catalog.json";

    private readonly string _baseDirectory;

    public ToolkitModuleService(string baseDirectory)
    {
        _baseDirectory = baseDirectory;
    }

    public ToolkitModuleInfo GetSqlPatcherInfo()
    {
        var bundledExecutable = ResolveBundledExecutablePath();
        if (File.Exists(bundledExecutable))
        {
            var bundledRoot = Path.GetDirectoryName(bundledExecutable);
            var patchCatalog = ReadPatchCatalogMetadata(bundledRoot);
            return new ToolkitModuleInfo
            {
                StatusText = "Bundled extension ready",
                LocationText = bundledExecutable,
                DetailText = BuildBundledModuleDetailText(patchCatalog),
                BuildText = BuildModuleBuildText(bundledExecutable),
                ModuleRootPath = bundledRoot,
                LaunchPath = bundledExecutable,
                CanLaunch = true,
                CanOpenWorkspace = !string.IsNullOrWhiteSpace(bundledRoot) && Directory.Exists(bundledRoot)
            };
        }

        var toolkitRoot = FindToolkitRoot();
        if (toolkitRoot is null)
        {
            return new ToolkitModuleInfo
            {
                StatusText = "Toolkit workspace not detected",
                LocationText = _baseDirectory,
                DetailText = "Run the support tool from the ME ACS toolkit workspace to detect the imported SQL patcher module.",
                BuildText = "Build date unavailable",
                CanLaunch = false,
                CanOpenWorkspace = false
            };
        }

        var moduleRoot = Path.Combine(toolkitRoot, "modules", SqlPatcherModuleFolder);
        if (!Directory.Exists(moduleRoot))
        {
            return new ToolkitModuleInfo
            {
                StatusText = "Module not imported yet",
                LocationText = moduleRoot,
                DetailText = "The toolkit repo is ready for the SQL patcher module, but the module folder does not exist yet.",
                BuildText = "Build date unavailable",
                ModuleRootPath = moduleRoot,
                CanLaunch = false,
                CanOpenWorkspace = false
            };
        }

        var projectPath = Path.Combine(moduleRoot, SqlPatcherProjectRelativePath);
        var launchPath = FindSqlPatcherExecutable(moduleRoot);
        if (!string.IsNullOrWhiteSpace(launchPath))
        {
            return new ToolkitModuleInfo
            {
                StatusText = "Imported and launchable",
                LocationText = launchPath,
                DetailText = "A built SQL patcher executable was found inside the toolkit workspace. Release packaging should still bundle it under Modules\\SqlPatcher.",
                BuildText = BuildModuleBuildText(launchPath),
                ModuleRootPath = moduleRoot,
                ProjectPath = projectPath,
                LaunchPath = launchPath,
                CanLaunch = true,
                CanOpenWorkspace = true
            };
        }

        return new ToolkitModuleInfo
        {
            StatusText = "Extension source imported",
            LocationText = File.Exists(projectPath) ? projectPath : moduleRoot,
            DetailText = "The SQL patcher source is inside the support-tool repo. Build the shared solution once to generate a launchable extension executable.",
            BuildText = ReadProjectVersion(projectPath) is string version
                ? $"Project version {version}"
                : "Build date unavailable",
            ModuleRootPath = moduleRoot,
            ProjectPath = projectPath,
            CanLaunch = false,
            CanOpenWorkspace = true
        };
    }

    public void LaunchSqlPatcher(ToolkitModuleInfo moduleInfo)
    {
        if (string.IsNullOrWhiteSpace(moduleInfo.LaunchPath) || !File.Exists(moduleInfo.LaunchPath))
        {
            throw new FileNotFoundException("The SQL patcher executable could not be found.", moduleInfo.LaunchPath);
        }

        Process.Start(new ProcessStartInfo
        {
            FileName = moduleInfo.LaunchPath,
            WorkingDirectory = Path.GetDirectoryName(moduleInfo.LaunchPath),
            UseShellExecute = true
        });
    }

    public void OpenModuleWorkspace(ToolkitModuleInfo moduleInfo)
    {
        var targetPath = moduleInfo.ModuleRootPath;
        if (string.IsNullOrWhiteSpace(targetPath) || !Directory.Exists(targetPath))
        {
            throw new DirectoryNotFoundException("The SQL patcher module folder could not be found.");
        }

        Process.Start(new ProcessStartInfo
        {
            FileName = targetPath,
            UseShellExecute = true
        });
    }

    private string? FindToolkitRoot()
    {
        var current = new DirectoryInfo(_baseDirectory);
        while (current is not null)
        {
            var solutionPath = Path.Combine(current.FullName, "ME_ACS_Toolkit.sln");
            var appProjectPath = Path.Combine(current.FullName, "MEACSSupportTool", "MEACSSupportTool.csproj");
            if (File.Exists(solutionPath) || File.Exists(appProjectPath))
            {
                return current.FullName;
            }

            current = current.Parent;
        }

        return null;
    }

    private string ResolveBundledExecutablePath()
    {
        var manifestPath = Path.Combine(_baseDirectory, BundledManifestPath);
        if (File.Exists(manifestPath))
        {
            try
            {
                var manifest = JsonSerializer.Deserialize<ToolkitManifest>(
                    File.ReadAllText(manifestPath),
                    new JsonSerializerOptions { PropertyNameCaseInsensitive = true });

                var executable = manifest?.Modules?
                    .FirstOrDefault(module => string.Equals(module.Id, "sql-patcher", StringComparison.OrdinalIgnoreCase))
                    ?.Executable;

                if (!string.IsNullOrWhiteSpace(executable))
                {
                    return Path.GetFullPath(Path.Combine(_baseDirectory, executable.Replace('/', Path.DirectorySeparatorChar)));
                }
            }
            catch
            {
                // Fall back to the conventional packaged location when the manifest is unavailable.
            }
        }

        return Path.GetFullPath(Path.Combine(_baseDirectory, BundledModuleRelativePath));
    }

    private static string? FindSqlPatcherExecutable(string moduleRoot)
    {
        var candidates = new List<string>
        {
            Path.Combine(moduleRoot, "artifacts", "bin", "Debug", "net8.0-windows", SqlPatcherExecutableName),
            Path.Combine(moduleRoot, "artifacts", "bin", "Release", "net8.0-windows", SqlPatcherExecutableName),
            Path.Combine(moduleRoot, "artifacts", "bin", "Release", "net8.0-windows", "win-x64", "publish", SqlPatcherExecutableName),
            Path.Combine(moduleRoot, "src", "ME_ACS_SQL_Patcher", "bin", "Debug", "net8.0-windows", SqlPatcherExecutableName),
            Path.Combine(moduleRoot, "src", "ME_ACS_SQL_Patcher", "bin", "Release", "net8.0-windows", SqlPatcherExecutableName),
            Path.Combine(moduleRoot, "src", "ME_ACS_SQL_Patcher", "bin", "Release", "net8.0-windows", "win-x64", "publish", SqlPatcherExecutableName),
            Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "MagDbPatcher", "app", SqlPatcherExecutableName)
        };

        foreach (var candidate in candidates)
        {
            if (File.Exists(candidate))
            {
                return candidate;
            }
        }

        var searchRoots = new[]
        {
            Path.Combine(moduleRoot, "artifacts", "bin"),
            Path.Combine(moduleRoot, "src", "ME_ACS_SQL_Patcher", "bin")
        };

        var discovered = searchRoots
            .Where(Directory.Exists)
            .SelectMany(root => Directory.EnumerateFiles(root, SqlPatcherExecutableName, SearchOption.AllDirectories))
            .Select(path => new FileInfo(path))
            .OrderByDescending(file => file.LastWriteTimeUtc)
            .FirstOrDefault();

        return discovered?.FullName;
    }

    private static string BuildModuleBuildText(string executablePath)
    {
        var buildDate = ReadBuildDate(executablePath);
        if (buildDate.HasValue)
        {
            return $"SQL Patcher build {buildDate.Value.AddHours(8):dd MMM yyyy HH:mm} MYT";
        }

        var version = FileVersionInfo.GetVersionInfo(executablePath).ProductVersion;
        if (!string.IsNullOrWhiteSpace(version))
        {
            return $"SQL Patcher version {version}";
        }

        return $"Built from {File.GetLastWriteTime(executablePath):dd MMM yyyy HH:mm}";
    }

    private static string BuildBundledModuleDetailText(PatchCatalogMetadata? patchCatalog)
    {
        if (patchCatalog is null || string.IsNullOrWhiteSpace(patchCatalog.Label))
        {
            return "The SQL patcher is bundled as a toolkit extension and launches from the packaged Modules\\SqlPatcher folder.";
        }

        return $"The SQL patcher is bundled as a toolkit extension. Patch library: {patchCatalog.Label}. {patchCatalog.Summary ?? "Catalog summary unavailable."}";
    }

    private static PatchCatalogMetadata? ReadPatchCatalogMetadata(string? moduleRoot)
    {
        if (string.IsNullOrWhiteSpace(moduleRoot))
        {
            return null;
        }

        var metadataPath = Path.Combine(moduleRoot, BundledPatchCatalogPath);
        if (!File.Exists(metadataPath))
        {
            return null;
        }

        try
        {
            return JsonSerializer.Deserialize<PatchCatalogMetadata>(
                File.ReadAllText(metadataPath),
                new JsonSerializerOptions { PropertyNameCaseInsensitive = true });
        }
        catch
        {
            return null;
        }
    }

    private static DateTime? ReadBuildDate(string executablePath)
    {
        var executableDirectory = Path.GetDirectoryName(executablePath);
        if (string.IsNullOrWhiteSpace(executableDirectory))
        {
            return null;
        }

        var buildDateFile = Path.Combine(executableDirectory, "build-date.txt");
        if (File.Exists(buildDateFile))
        {
            var raw = File.ReadAllText(buildDateFile).Trim();
            if (DateTime.TryParse(raw, out var parsed))
            {
                return parsed;
            }
        }

        return File.Exists(executablePath) ? File.GetLastWriteTime(executablePath) : null;
    }

    private static string? ReadProjectVersion(string projectPath)
    {
        if (!File.Exists(projectPath))
        {
            return null;
        }

        const string versionTagStart = "<Version>";
        const string versionTagEnd = "</Version>";
        foreach (var line in File.ReadLines(projectPath))
        {
            var startIndex = line.IndexOf(versionTagStart, StringComparison.Ordinal);
            if (startIndex < 0)
            {
                continue;
            }

            var endIndex = line.IndexOf(versionTagEnd, startIndex, StringComparison.Ordinal);
            if (endIndex < 0)
            {
                continue;
            }

            startIndex += versionTagStart.Length;
            return line[startIndex..endIndex].Trim();
        }

        return null;
    }

    private sealed class ToolkitManifest
    {
        public List<ToolkitManifestModule>? Modules { get; init; }
    }

    private sealed class ToolkitManifestModule
    {
        public string? Id { get; init; }

        public string? Executable { get; init; }
    }

    private sealed class PatchCatalogMetadata
    {
        public string? Label { get; init; }

        public string? Summary { get; init; }
    }
}
