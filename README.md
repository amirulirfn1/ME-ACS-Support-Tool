# ME ACS Support Tool

Windows support toolkit for MAG support staff.

## Repository Direction

This repository is now the working home for the combined support toolkit.

Current product direction:

1. Keep `ME ACS Support Tool` as the main support-team entry point.
2. Keep `ME_ACS SQL Patcher` inside this repository as a dedicated imported module under `modules/ME_ACS_SQL_Patcher`.
3. Preserve the existing SQL patcher workflow first, then decide later whether deeper UI/code merging is worthwhile.

This means the support team can move toward one toolkit now, while development still keeps the SQL patcher stable as a separate project during migration.

## Current Actions

1. `RabbitMQ Repair`
   - Checks for admin access before running
   - Detects RabbitMQ and Erlang versions
   - Stops related processes and service
   - Uninstalls, cleans, downloads, reinstalls, and rewrites the RabbitMQ nodename
   - Logs each step locally

2. `Solve Client Lag`
   - Detects a local SQL Server instance
   - Targets database `magetegra`
   - Checks whether `dbo.events` exists
   - Skips safely if index `IX_events` already exists
   - Creates the index from the bundled SQL script if needed

3. `Install SSMS`
   - Detects whether SQL Server Management Studio is already installed
   - Skips safely if SSMS is already present
   - Downloads the installer from `https://aka.ms/ssmsfullsetup`
   - Launches the setup wizard for one-time installation

## Toolkit Modules

The toolkit now includes:

1. `SQL Patcher`
   - Uses the imported `ME_ACS SQL Patcher` codebase and release flow as the starting point
   - Is currently surfaced as a launched module from the support tool
   - May later share logging, packaging, environment checks, and common support services

See [docs/Toolkit-Migration-Plan.md](docs/Toolkit-Migration-Plan.md) for the draft migration approach.

## Logs

The app stores logs and run history under:

- `%ProgramData%\MagSupportTool`

If `%ProgramData%` is not writable, it falls back to:

- `%LocalAppData%\MagSupportTool`

## Build

```powershell
dotnet build .\ME_ACS_Toolkit.sln
```

This builds:

- `MEACSSupportTool\MEACSSupportTool.csproj`
- `modules\ME_ACS_SQL_Patcher\src\ME_ACS_SQL_Patcher\ME_ACS_SQL_Patcher.csproj`

## Package

Create a portable toolkit folder and zip with:

```powershell
.\build\package.ps1
```

This produces:

- `output\ME_ACS_Support_Tool\`
- `dist\ME_ACS_Support_Tool-portable.zip`

The bundled SQL patcher is placed under:

- `output\ME_ACS_Support_Tool\Modules\SqlPatcher\ME_ACS_SQL_Patcher.exe`

## Release

Create the full installer, portable handoff zip, and update feed metadata with:

```powershell
dotnet tool restore
.\build\release.ps1
```

This produces:

- `output\ME_ACS_Support_Tool\`
- `dist\ME ACS Support Tool Setup.zip`
- `dist\ME ACS Support Tool Portable.zip`
- `feed\support-tool\latest.json`
- `feed\support-tool\MEACSSupportTool-win-Setup-<builddate>.exe`

Optional signing inputs for `release.ps1`:

- `-SignParams "<signtool arguments>"`
- `-SignTemplate "<custom signing command with {{file}} or {{file...}}>"`
- `-AzureTrustedSignFile "<path to Azure Trusted Signing metadata json>"`

Only provide one signing mode at a time. If none are supplied, the build stays unsigned.

## Run

```powershell
.\output\ME_ACS_Support_Tool\MEACSSupportTool.exe
```

Or double-click:

- `Run ME ACS Support Tool.bat`
