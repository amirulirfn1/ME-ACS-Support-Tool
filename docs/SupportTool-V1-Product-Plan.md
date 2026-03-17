# ME ACS Support Tool V1

## Product Goal

Build a simple Windows support launcher that lets the MAG support team run approved repair actions on a dealer PC through AnyDesk with minimal typing, minimal training, and clear safety checks.

V1 should focus on:

1. Reducing support time for repeated dealer issues.
2. Standardizing how fixes are run.
3. Capturing logs and outcomes for audit and troubleshooting.
4. Making support actions mostly "click and run".

## Primary User

- MAG support team

## Operating Context

- Tool is run on the dealer PC or on any Windows PC that can access the dealer environment.
- Support staff typically operate through AnyDesk.
- No login should be required in V1.
- Internet access is available.
- Environment varies by dealer.

## V1 Scope

### Initial support actions

1. Fix RabbitMQ after PC rename / host rename issue
2. Solve old SoyalEtegra client lag issue on local SQL database `magetegra`

### Required V1 capabilities

1. Show available repair actions in a dashboard.
2. Detect prerequisites before running each action.
3. Run actions automatically with minimal user input.
4. Show progress, success, failure, and next steps.
5. Save execution logs and error logs locally.
6. Keep a history of what was run, when, and on which machine.

## Product Principles

1. One-click where safe.
2. Guided where risky.
3. Fail with a useful message, not a cryptic console error.
4. Every action must be repeatable and logged.
5. Support staff should not need to remember commands, SQL, file paths, or service names.

## Recommended Product Shape

### App type

A small Windows desktop launcher dashboard.

### Recommendation for V1

Use a self-contained .NET desktop app with a very small UI and an internal action runner.

Why:

- Easy for support team to use over AnyDesk.
- Can wrap `.bat`, PowerShell, and SQL actions behind a single interface.
- Better control of logging, prerequisite checks, and error handling than raw scripts.
- Easy to add more support actions later.

## High-Level User Flow

1. Support opens the tool on the dealer PC.
2. Tool shows machine summary:
   - Computer name
   - Current Windows user
   - Admin status
   - SQL availability
   - Internet availability
3. Support selects a repair action from the dashboard.
4. Tool shows:
   - What this action does
   - What it will change
   - Preconditions
   - Risks / restart requirements
5. Support clicks `Run`.
6. Tool performs:
   - Environment checks
   - Step-by-step execution
   - Real-time logging
   - Success or error summary
7. Tool saves:
   - Full log
   - Error log if failed
   - Execution history record

## V1 Dashboard Layout

### Top area

- Dealer PC summary
- Environment health badges
- Last run status

### Main area

Two action cards:

1. `RabbitMQ Repair`
   - Fix RabbitMQ after PC rename or broken service setup
   - Requires Administrator
   - Uses internet download

2. `Solve Client Lag`
   - Apply SQL optimization for older SoyalEtegra
   - Runs against local database `magetegra`
   - Requires SQL connectivity

### Bottom area

- Run history
- Open logs
- Export logs

## Action Model

Each support action should be defined as a structured unit, not hardcoded directly into the UI.

Suggested action metadata:

- `Id`
- `Name`
- `Description`
- `Category`
- `RequiresAdmin`
- `RequiresInternet`
- `RequiresSql`
- `ConfirmationMessage`
- `EstimatedDuration`
- `Steps`
- `SuccessMessage`
- `FailureHints`

This allows future actions to be added consistently.

## V1 Action Design

### 1. RabbitMQ Repair

#### User story

As a MAG support agent, I want to repair RabbitMQ after a dealer renames the PC so that MagEtegra services work again without manual uninstall and reinstall work.

#### Source input

Existing script:

- `C:\Users\SupN\Desktop\Amirul\MagEtegra\Scripts\fix_rabbitmq_full.bat`

#### What the action should do

1. Check admin rights.
2. Detect installed RabbitMQ and Erlang versions if possible.
3. Stop MAG and RabbitMQ related processes.
4. Uninstall RabbitMQ and Erlang.
5. Clean leftover folders.
6. Download installers.
7. Reinstall both components.
8. Reset RabbitMQ nodename to `rabbit@localhost`.
9. Start RabbitMQ service.
10. Report result and suggested next step.

#### Improvements over raw batch script

1. Show clear pre-check result before execution.
2. Save each step result to a log file.
3. Validate download URLs before full execution.
4. Detect whether service is running at the end.
5. Detect common failure cases:
   - not admin
   - download blocked
   - service cannot start
   - installer missing
6. Show final instruction:
   - restart MagServer as Administrator

#### Risks

- Uninstall/reinstall is a destructive repair action.
- Internet dependency for installers.
- Version auto-detection may fail on unusual installs.

#### V1 UX note

Require one confirmation checkbox:

- `I understand this will reinstall RabbitMQ and Erlang on this PC.`

### 2. Solve Client Lag

#### User story

As a MAG support agent, I want to apply a known SQL performance fix to older SoyalEtegra installs so that the client becomes responsive without manually opening SQL Server Management Studio.

#### Source input

Existing SQL:

- `C:\Users\SupN\Desktop\Amirul\MagEtegra\Scripts\Solve Client Lag Issue\Solve Client Lag Issues.sql`

#### Current SQL content

Creates index:

- `IX_events` on `dbo.events(tran_date, date_system)`

#### What the action should do

1. Check whether local SQL Server is reachable.
2. Check whether database `magetegra` exists.
3. Check whether table `dbo.events` exists.
4. Check whether index `IX_events` already exists.
5. If not present, create the index.
6. If already present, return a safe `Already applied` result.
7. Save execution output to log.

#### Improvements over raw SQL script

1. No need to open SSMS manually.
2. Add idempotent behavior so the action is safe to rerun.
3. Add pre-checks for DB and object existence.
4. Return friendly messages rather than SQL-only errors.

#### Risks

- Index creation can take time on large tables.
- SQL connection details may differ by dealer.

#### V1 assumption

Default target is local SQL instance and database `magetegra`.

## Environment Detection

The launcher should detect and display:

- Computer name
- OS version
- Is running as Administrator
- Internet reachable
- RabbitMQ service installed
- RabbitMQ service running
- SQL Server reachable locally
- Database `magetegra` present

This should happen automatically on startup and when the user clicks `Refresh`.

## Logging and Audit

### Required outputs

For every action run, save:

1. Timestamp
2. Machine name
3. Windows user
4. Action name
5. Start and end time
6. Outcome: success / failed / skipped / already applied
7. Step-by-step log
8. Error details

### Suggested local storage

```text
%ProgramData%\MagSupportTool\
  Logs\
  History\
  Temp\
```

### Suggested files

- One log file per run
- One JSON history file or lightweight local database

## Suggested Technical Architecture

## Option recommended for V1

.NET desktop app with:

1. Dashboard UI
2. Action runner service
3. Logging service
4. Environment detection service
5. Script adapters

### Execution adapters

The app should support three action types:

1. Process action
   - run `.bat`, `.cmd`, `.exe`, or PowerShell
2. SQL action
   - run SQL against local database with pre-checks
3. Composite action
   - multiple steps, mixing scripts and validations

### Why this structure works

- RabbitMQ repair can remain process/script based at first.
- SQL fix can be executed through a database adapter.
- Future fixes can reuse the same framework.

## Recommended V1 Folder Structure

```text
/src
  /MagSupportTool.App
  /MagSupportTool.Core
  /MagSupportTool.Actions
  /MagSupportTool.Infrastructure
/actions
  rabbitmq-repair.json
  solve-client-lag.json
/scripts
  fix_rabbitmq_full.bat
/sql
  solve_client_lag.sql
/docs
  SupportTool-V1-Product-Plan.md
```

## Example Action Definitions

### RabbitMQ action

```json
{
  "id": "rabbitmq-repair",
  "name": "RabbitMQ Repair",
  "requiresAdmin": true,
  "requiresInternet": true,
  "type": "composite",
  "scriptPath": "scripts/fix_rabbitmq_full.bat"
}
```

### SQL action

```json
{
  "id": "solve-client-lag",
  "name": "Solve Client Lag",
  "requiresSql": true,
  "database": "magetegra",
  "type": "sql",
  "sqlPath": "sql/solve_client_lag.sql"
}
```

## Safety Rules

1. Show admin requirement before running admin-only actions.
2. Block SQL actions if DB checks fail.
3. Do not rerun index creation blindly if index already exists.
4. Show explicit confirmation for destructive actions.
5. Never hide raw error details from the log.
6. Allow easy copy/export of the final result for support reporting.

## Non-Goals for V1

1. User login / role management
2. Cloud sync
3. Remote execution from a central server
4. Automatic dealer inventory management
5. Auto-update framework

## Suggested V1 Success Metrics

1. Reduce average RabbitMQ fix time.
2. Reduce number of manual SSMS steps.
3. Increase first-time fix success rate.
4. Make every support action traceable in logs.

## Delivery Plan

### Phase 1

- Build launcher shell
- Add environment summary
- Add RabbitMQ Repair action
- Add Solve Client Lag action
- Add local logs and history

### Phase 2

- Add packaging / installer
- Add bundled dependencies if needed
- Add more support actions
- Add exportable support report

### Phase 3

- Optional central action catalog
- Optional central log upload
- Optional dealer profile presets

## Product Decision Summary

For your use case, V1 should be:

- a Windows launcher dashboard
- no login
- built for support staff over AnyDesk
- mostly one-click execution
- based on structured support actions
- backed by strong logging and error capture

The first two actions should be:

1. RabbitMQ Repair
2. Solve Client Lag

## Recommended Next Build Step

Create a clickable Windows prototype with:

1. Home dashboard
2. Machine status panel
3. RabbitMQ Repair card
4. Solve Client Lag card
5. Run log window
6. Local history list

After that, wire the existing batch script and replace the SQL script with an idempotent SQL execution flow inside the app.
