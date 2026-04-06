@echo off
setlocal

set "APP=%~dp0output\ME_ACS_Support_Tool\MEACSSupportTool.exe"

if not exist "%APP%" (
    echo ME ACS Support Tool release build was not found.
    echo Expected: %APP%
    pause
    exit /b 1
)

start "" "%APP%"
