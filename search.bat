
@echo off

set /p search=Search for: 

powershell -ExecutionPolicy Bypass -File "%~dp0Search-Meetings.ps1" "%search%"

echo.
pause
