@echo off
REM Claude Greeter - Stop Script (Windows)
REM Gracefully stops the background application

setlocal enabledelayedexpansion

echo ========================================
echo Claude Greeter - Stop Script
echo ========================================
echo.

REM Get script directory
cd /d "%~dp0"

REM Check if PID file exists
if not exist "app.pid" (
    echo [WARNING] No PID file found. Application may not be running.
    pause
    exit /b 0
)

REM Read PID
set /p APP_PID=<app.pid

REM Check if process is running
tasklist /FI "PID eq %APP_PID%" 2>nul | find "%APP_PID%" >nul
if %errorlevel% neq 0 (
    echo [WARNING] Process ^(PID: %APP_PID%^) is not running.
    del app.pid
    pause
    exit /b 0
)

REM Stop the process
echo Stopping application ^(PID: %APP_PID%^)...
taskkill /PID %APP_PID% /F >nul 2>&1

REM Wait a moment
timeout /t 2 /nobreak >nul

REM Verify stopped
tasklist /FI "PID eq %APP_PID%" 2>nul | find "%APP_PID%" >nul
if %errorlevel% neq 0 (
    echo [OK] Application stopped successfully
    del app.pid
) else (
    echo [ERROR] Failed to stop process
    pause
    exit /b 1
)

echo ========================================
pause
endlocal
