# Patch Operator Guide

Use this flow when you need to add or distribute new SQL scripts without shipping a full app release.

## Add or Update SQL Content

1. Add the new `.sql` file under the correct folder in `src\patches\`.
2. Update `src\patches\versions.json` or use the Admin Tools/catalog helpers so the new version and patch links are valid.
3. Run `dotnet test ME_ACS_SQL_Patcher.sln`.
4. Run the app locally and confirm the new version path appears as expected.

## Publish a Patch Pack

1. Run:

```powershell
.\New-PatchPack.ps1 -PatchesFolder .\src\patches -PackVersion <YYYYMMDD-or-semver> -OutFile .\dist\MagPatchPack-<version>.zip -Notes "<what changed>"
```

2. Share the generated ZIP with teammates.
3. Teammates open the app and click `Import Patch Pack (.zip)`.
4. The app will:
   - validate the ZIP,
   - atomically replace the active patch library,
   - create a rollback backup under `%LOCALAPPDATA%\MagDbPatcher\backups\`,
   - archive the imported ZIP under `%LOCALAPPDATA%\MagDbPatcher\patch-packs\`.

## Ship a Full App Release Instead

Ship a full release instead of a patch pack when:

- the UI changed,
- runtime paths or settings changed,
- SQL execution behavior changed,
- bundled dependencies changed.

Use:

```powershell
dotnet tool restore
.\release.ps1
```
