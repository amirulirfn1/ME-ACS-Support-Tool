# ME ACS Support Tool

V1 desktop launcher for MAG support staff.

## Current actions

1. `RabbitMQ Repair`
   - Checks for admin access
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

## Logs

The app stores logs and run history under:

- `%ProgramData%\MagSupportTool`

If `%ProgramData%` is not writable, it falls back to:

- `%LocalAppData%\MagSupportTool`

## Build

```powershell
dotnet build .\MEACSSupportTool\MEACSSupportTool.csproj
```

## Run

```powershell
.\Release\MEACSSupportTool.exe
```

Or double-click:

- `Run ME ACS Support Tool.bat`
