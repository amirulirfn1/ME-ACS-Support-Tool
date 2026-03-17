# ME ACS Support Tool Smoke Test Checklist

Use this checklist on a test PC before wider internal rollout.

## 1. Launch

- Start the app from `Run ME ACS Support Tool.bat`.
- Confirm the main window opens without errors.
- Confirm the hero section shows machine readiness details.
- Click `Refresh Status` and confirm the status timestamp updates.

## 2. Logs And History

- Run any non-destructive action or a safe test flow.
- Confirm the activity console expands automatically during the run.
- Confirm `Open Current Log` opens the latest log file.
- Confirm the run appears under `Recent runs`.
- Double-click a recent run and confirm its log opens.

## 3. Install SSMS

- Test on a PC without SQL Server Management Studio installed.
- Run `Install SSMS`.
- Confirm the installer downloads and opens.
- Complete the setup.
- Refresh status and confirm `SSMS` changes to `Installed`.
- Re-run `Install SSMS` and confirm it skips safely because SSMS is already installed.

## 4. Solve Client Lag

- Test on a PC with a reachable local SQL Server instance.
- Confirm the `magetegra` database exists.
- Run `Solve Client Lag`.
- Confirm success when `IX_events` is missing.
- Re-run it and confirm it reports `AlreadyApplied` when the index already exists.

## 5. RabbitMQ Repair

- Test only on a non-production machine that matches the expected RabbitMQ/Erlang scenario.
- Run the app as Administrator.
- Confirm internet access is available before starting the repair.
- Run `RabbitMQ Repair`.
- Confirm Erlang and RabbitMQ installers are downloaded before uninstall begins.
- Confirm RabbitMQ is running after the repair completes.
- Confirm MagServer can be restarted successfully afterward.

## 6. Basic Failure Cases

- Start the app without Administrator rights and confirm RabbitMQ Repair blocks cleanly.
- Disconnect internet and confirm internet-dependent actions fail with a clear message.
- Confirm the app stays responsive after a failed action and buttons become usable again.
