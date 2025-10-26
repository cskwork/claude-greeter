@echo off
REM Claude Greeter - Status Script (Windows)
REM Check application status and show recent logs

setlocal enabledelayedexpansion

echo ========================================
echo Claude Greeter - Status
echo ========================================
echo.

REM Get script directory
cd /d "%~dp0"

REM Check if PID file exists
if not exist "app.pid" (
    echo [X] Application is NOT running
    echo     ^(No PID file found^)
    echo.
    echo To start: setup.bat
    pause
    exit /b 1
)

REM Read PID
set /p APP_PID=<app.pid

REM Check if process is running
tasklist /FI "PID eq %APP_PID%" 2>nul | find "%APP_PID%" >nul
if %errorlevel% neq 0 (
    echo [X] Application is NOT running
    echo     ^(Process %APP_PID% not found^)
    del app.pid
    echo.
    echo To start: setup.bat
    pause
    exit /b 1
)

echo [OK] Application is RUNNING
echo.
echo Process Details:
echo   PID: %APP_PID%

REM Get process uptime (if available)
for /f "skip=1 tokens=1" %%i in ('tasklist /FI "PID eq %APP_PID%" /FO TABLE /NH') do (
    echo   Process: %%i
)

echo.

REM Check API endpoint
echo API Status:
where curl >nul 2>&1
if %errorlevel% equ 0 (
    curl -s http://localhost:8000 > temp_response.json 2>nul
    if !errorlevel! equ 0 (
        echo   [OK] API is responding at http://localhost:8000
        echo.
        echo Schedule Information:
        type temp_response.json
        del temp_response.json
    ) else (
        echo   [!] API is not responding
        echo   Check logs for details
        if exist temp_response.json del temp_response.json
    )
) else (
    echo   ^(curl not available to test API^)
    echo   Install curl or test manually: http://localhost:8000
)

echo.
echo ========================================
echo Recent Logs ^(last 20 lines^):
echo ========================================

REM Show recent logs (Windows equivalent of tail)
if exist "log\app.log" (
    powershell -Command "Get-Content log\app.log -Tail 20"
) else (
    echo [!] No log file found
)

echo.
echo ========================================
echo Useful Commands:
echo   stop.bat           - Stop application
echo   curl http://localhost:8000/schedule - Get schedule info
echo   curl -X POST http://localhost:8000/greet - Manual trigger
echo ========================================
pause
endlocal
