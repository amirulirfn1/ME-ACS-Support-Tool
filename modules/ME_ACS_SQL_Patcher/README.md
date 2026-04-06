# ME_ACS SQL Patcher

Windows desktop tool for patching MagEtegra SQL Server backup files (`.bak`) from one supported version to another.

## Migration Notice

This project is planned to be migrated into the broader `ME ACS Support Tool` toolkit.

Current direction:

1. `ME ACS Support Tool` becomes the main support-team entry point.
2. `ME_ACS SQL Patcher` remains the supported SQL patching module during the migration.
3. The first combine step is repository and release consolidation, not a risky rewrite of the existing patcher workflow.

Until that migration is complete, this repository remains the source of truth for the SQL patcher application, patch library, tests, and packaging flow.

## Planned End State

The target product shape is:

- One support-facing toolkit for the MAG support team.
- SQL patching kept as a dedicated module inside that toolkit.
- A gradual migration path that protects the already-working patcher.

In practical terms, the expected rollout is:

1. Move this repository into the `ME ACS Support Tool` repository.
2. Keep the SQL patcher as its own project inside the shared solution first.
3. Let the support tool act as the launcher or hub.
4. Only merge code deeper when shared components are clearly worth extracting.

See the destination toolkit repository for the active migration plan and combined-tool roadmap.

## What This Repo Contains

- WPF desktop application targeting `.NET 8`
- SQL patch library under `patches/`
- xUnit test project covering patching, settings, and storage behavior
- Packaging and install scripts under `build/`

## Core Workflow

1. Select a source `.bak` file.
2. Choose the starting version.
3. Let the app resolve the latest reachable target version.
4. Run the patch workflow against a local SQL Server instance.

Default SQL target is `.\\MAGSQL`.

The app now treats the install folder as read-only runtime content. Settings, logs, backups, imported patch packs, and the active patch library live under `%LOCALAPPDATA%\MagDbPatcher\...` so manual app upgrades do not wipe teammate state.

## Repository Structure

```text
.
|-- src/ME_ACS_SQL_Patcher/  WPF application source, assets, themes, and services
|-- tests/MagDbPatcher.Tests/ Automated test project
|-- build/                  Packaging, install, and support scripts
|-- patches/                Versioned SQL patch definitions
|-- artifacts/              Generated build output only
|-- output/                 Generated portable handoff folder
|-- dist/                   Generated release ZIPs
|-- ME_ACS_SQL_Patcher.sln  Solution file
```

## Development

### Requirements

- Windows
- .NET SDK 8.x
- Local SQL Server instance (Express, LocalDB, or full SQL Server)
- Permissions to restore, back up, create, and drop databases

### Build

```powershell
dotnet build ME_ACS_SQL_Patcher.sln
```

### Test

```powershell
dotnet test ME_ACS_SQL_Patcher.sln
```

## Packaging

Create a smoke-test publish folder and versioned handoff ZIP with:

```powershell
.\build\package.ps1
```

Create the full release set, including the Velopack installer artifacts, with:

```powershell
dotnet tool restore
.\build\release.ps1
```

`build\release.ps1` produces:

- `output\` for local verification
- `dist\ME_ACS_SQL_Patcher-<version>.zip` for manual handoff
- `dist\installer\` with installer/update artifacts such as `ME_ACS_SQL_Patcher-win-Setup.exe`
- `dist\release-manifest.json` describing the release outputs

`build\package.ps1` still produces:

- `output\` for local verification
- `dist\ME_ACS_SQL_Patcher-<version>.zip` for manual handoff

Default packaging is self-contained single-file `win-x64`, so target machines do not need a separate .NET runtime installation.

Install the published build locally with:

```powershell
.\build\scripts\Install-Portable.ps1
```

By default the install script uses `output\` as its source and installs the EXE under `%LOCALAPPDATA%\MagDbPatcher\app`. If the source folder contains legacy portable `settings.json`, `logs\`, `backups\`, or `patches\`, the script carries them forward into the managed LocalAppData layout when missing.

## Support Handoff

For a manual teammate handoff:

1. Build the release with `.\build\release.ps1`.
2. Send either `dist\installer\ME_ACS_SQL_Patcher-win-Setup.exe` or `dist\ME_ACS_SQL_Patcher-<version>.zip`.
3. Teammates install once, then run the app from the installed location.
4. Future app updates are manual by default: replace the installed app with the next release package.
5. Optional LAN-hosted prototype: publish `dist\installer\` into `update-host\feed` and point installed clients to that UNC path for internal update checks.
6. Future SQL content updates should be delivered as patch packs whenever possible.

Installed runtime layout:

```text
%LOCALAPPDATA%\MagDbPatcher\
  app\                     installed app binaries
  settings.json
  logs\
  backups\
  patches\                 active patch library used by the app
  patch-packs\             archived imported patch packs
```

Runtime notes:

- `app\patches\` is only the bundled baseline library that ships with the app.
- `%LOCALAPPDATA%\MagDbPatcher\patches\` is the active patch library used at runtime.
- `%LOCALAPPDATA%\MagDbPatcher\backups\` stores patch-library rollback backups created during patch-pack import.
- `%LOCALAPPDATA%\MagDbPatcher\patch-packs\` stores imported patch pack ZIPs for traceability.
- Temporary restore workspace is stored in `%ProgramData%\ME_ACS_SQL_Patcher\temp`.

## Patch Updates

The normal workflow is:

1. Ship a full app release for binary/UI/runtime changes.
2. Ship a patch pack ZIP for new SQL scripts and patch-library-only changes.
3. If you want to test PC-hosted app updates on your office network, use the scripts in `update-host\` and share that feed folder from your machine.

The application supports importing a patch pack ZIP with this structure:

```text
MagPatchPack.zip
  patch-pack.json
  patches/
    versions.json
    patcher.config.json
    <version folders...>/*.sql
```

Create a patch pack with:

```powershell
.\build\tools\New-PatchPack.ps1 -PatchesFolder .\patches -PackVersion 20260203 -OutFile .\MagPatchPack.zip -Notes "7.2.3 build patches"
```

After a patch pack import, the app validates the ZIP, swaps the active patch library atomically, stores a rollback backup, and archives the imported ZIP under `%LOCALAPPDATA%\MagDbPatcher\patch-packs\`.

See [PATCH_OPERATOR_GUIDE.md](build/PATCH_OPERATOR_GUIDE.md) for the operator workflow when adding a new SQL script or version.

## CI

GitHub Actions is configured to restore, build, and test the solution on Windows for pushes to `main` and pull requests.

## Troubleshooting

| Issue | Suggested action |
| --- | --- |
| App does not open | Run the installed `ME_ACS_SQL_Patcher-win-Setup.exe` again or reinstall from the latest release |
| Missing runtime error | Rebuild using `.\build\release.ps1` or `.\build\package.ps1` in self-contained mode |
| Startup says package is incomplete | Verify the bundled `app\patches\versions.json` exists in the published output |
| SQL Server not found | Install SQL Server Express or LocalDB |
| No upgrade path | Verify `versions.json` and patch definitions |
| Version list looks wrong | Check the managed active patch library under `%LOCALAPPDATA%\MagDbPatcher\patches` or the configured custom folder |

## Key Files

| File | Responsibility |
| --- | --- |
| `src/ME_ACS_SQL_Patcher/MainWindow.xaml` | Main user interface |
| `src/ME_ACS_SQL_Patcher/MainWindow.xaml.cs` | Main window composition and startup interactions |
| `src/ME_ACS_SQL_Patcher/Infrastructure/AppRuntimePaths.cs` | Installed app layout for bundled content, LocalAppData user state, temp data, and backups |
| `src/ME_ACS_SQL_Patcher/Services/PortableAppBootstrapService.cs` | Startup validation, LocalAppData workspace creation, and bundled-library verification |
| `src/ME_ACS_SQL_Patcher/Services/PortableDataMigrationService.cs` | First-run import of legacy portable data into the managed app-data layout |
| `src/ME_ACS_SQL_Patcher/Services/PatchStorageService.cs` | Active patch-folder resolution |
| `src/ME_ACS_SQL_Patcher/Services/VersionService.cs` | Version graph and reachable upgrade path logic |
| `src/ME_ACS_SQL_Patcher/Services/PatchPackService.cs` | Patch-pack validation, backup, and atomic swap |
| `build/package.ps1` | Smoke-test publish and handoff ZIP generation |
| `build/release.ps1` | Full release pipeline including Velopack installer artifacts |
