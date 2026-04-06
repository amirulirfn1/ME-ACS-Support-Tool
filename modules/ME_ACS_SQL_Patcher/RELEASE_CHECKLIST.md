# Release Checklist

## Package

1. Run `dotnet build ME_ACS_SQL_Patcher.sln`.
2. Run `dotnet test ME_ACS_SQL_Patcher.sln`.
3. Run `dotnet tool restore`.
4. Run `.\release.ps1`.

## Smoke Test

1. Launch `output\ME_ACS_SQL_Patcher.exe`.
2. Confirm the startup window shows the current build label.
3. Confirm the main dashboard opens and patches load without validation errors.
4. Confirm `%LOCALAPPDATA%\MagDbPatcher\settings.json`, `logs\`, `backups\`, and `patches\` are created after first run.
5. Confirm patch detection and version selectors still work with the active LocalAppData patch library.
6. Click `Check Updates` and confirm the server status shows correctly.

## Support Handoff

1. Share `dist\ME_ACS_SQL_Patcher-<version>.zip` — contains Setup.exe + portable folder.
2. Tell support where runtime data lives:
   `%LOCALAPPDATA%\MagDbPatcher\settings.json`,
   `%LOCALAPPDATA%\MagDbPatcher\logs\`,
   `%LOCALAPPDATA%\MagDbPatcher\backups\`,
   `%LOCALAPPDATA%\MagDbPatcher\patches\`.

## SQL Content Updates

1. Prefer generating a patch pack ZIP for script-only changes.
2. Confirm importing the patch pack updates the active library and creates a rollback backup.
3. Record the pack version shared with teammates.
