@echo off
setlocal

set "APP=%~dp0Release\MEACSSupportTool.exe"

if not exist "%APP%" (
    echo ME ACS Support Tool release build was not found.
    echo Expected: %APP%
    pause
    exit /b 1
)

start "" "%APP%"
