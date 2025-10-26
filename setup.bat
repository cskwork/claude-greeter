@echo off
REM Claude Greeter - Automated Setup Script (Windows)
REM This script installs dependencies and runs the application in background

setlocal enabledelayedexpansion

echo ========================================
echo Claude Greeter - Setup Script
echo ========================================
echo.

REM Get script directory
set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"

REM Check Node.js
echo [1/7] Checking Node.js installation...
where node >nul 2>&1
if %errorlevel% neq 0 (
    echo [WARNING] Node.js is not installed
    echo.
    echo Node.js is required for Claude Code CLI
    echo Please choose an installation method:
    echo   1. Install via Chocolatey ^(recommended^)
    echo   2. Manual download from nodejs.org
    echo   3. Skip Node.js installation
    echo.
    choice /c 123 /n /m "Choose option (1/2/3): "

    if errorlevel 3 (
        echo Skipping Node.js installation...
    ) else if errorlevel 2 (
        echo Opening nodejs.org in browser...
        start https://nodejs.org/
        echo Please install Node.js and run this script again
        pause
        exit /b 1
    ) else if errorlevel 1 (
        echo Installing Node.js via Chocolatey...
        where choco >nul 2>&1
        if !errorlevel! neq 0 (
            echo Chocolatey is not installed. Installing Chocolatey first...
            powershell -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
        )
        choco install nodejs -y
        refreshenv
    )
) else (
    for /f "tokens=*" %%i in ('node --version') do set NODE_VERSION=%%i
    echo [OK] Found: Node.js !NODE_VERSION!
)
echo.

REM Check Claude Code CLI
echo [2/7] Checking Claude Code CLI...
where claude >nul 2>&1
if %errorlevel% neq 0 (
    echo Claude Code CLI not found. Installing globally...
    call npm install -g @anthropic-ai/claude-code
    if !errorlevel! neq 0 (
        echo [ERROR] Failed to install Claude Code CLI
        echo Please run: npm install -g @anthropic-ai/claude-code
        pause
        exit /b 1
    )
    echo [OK] Claude Code CLI installed
) else (
    echo [OK] Claude Code CLI already installed
)
echo.

REM Check Python
echo [3/7] Checking Python installation...
where python >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Python is not installed
    echo Please install Python from: https://www.python.org/downloads/
    echo Make sure to check "Add Python to PATH" during installation
    pause
    exit /b 1
)
for /f "tokens=*" %%i in ('python --version') do set PYTHON_VERSION=%%i
echo [OK] Found: !PYTHON_VERSION!
echo.

REM Create virtual environment
echo [4/7] Setting up virtual environment...
if not exist "venv" (
    echo Creating new virtual environment...
    python -m venv venv
    if !errorlevel! neq 0 (
        echo [ERROR] Failed to create virtual environment
        pause
        exit /b 1
    )
    echo [OK] Virtual environment created
) else (
    echo [OK] Virtual environment already exists
)
echo.

REM Activate virtual environment and install dependencies
echo [5/7] Installing Python dependencies...
call venv\Scripts\activate.bat
python -m pip install --upgrade pip -q
pip install -r requirements.txt -q
if %errorlevel% neq 0 (
    echo [ERROR] Failed to install dependencies
    pause
    exit /b 1
)
echo [OK] Dependencies installed
echo.

REM Setup .env file
echo [6/7] Configuring environment...
if not exist ".env" (
    if exist ".env.example" (
        copy .env.example .env >nul
        echo [OK] Created .env from .env.example
        echo [!] Please edit .env to configure START_TIME and other settings
    ) else (
        echo [WARNING] .env.example not found
        echo Creating default .env...
        (
            echo # Start time in 24-hour format ^(HH:MM^) - will run every 5 hours from this time
            echo START_TIME=09:00
            echo.
            echo # Optional: Timezone ^(defaults to system timezone^)
            echo # TIMEZONE=Asia/Seoul
            echo.
            echo # Optional: Prevent window - skip job execution during these hours
            echo # Format: HH:MM ^(24-hour format^)
            echo # Example: PREVENT_START_TIME=23:00, PREVENT_END_TIME=04:00 prevents execution from 11 PM to 4 AM
            echo PREVENT_START_TIME=23:00
            echo PREVENT_END_TIME=04:00
        ) > .env
        echo [OK] Created default .env
    )
) else (
    echo [OK] .env file already exists
)
echo.

REM Create log directory
if not exist "log" mkdir log

REM Run in background
echo [7/7] Starting application in background...

REM Check if already running
if exist "app.pid" (
    set /p OLD_PID=<app.pid
    tasklist /FI "PID eq !OLD_PID!" 2>nul | find "!OLD_PID!" >nul
    if !errorlevel! equ 0 (
        echo [WARNING] Application is already running ^(PID: !OLD_PID!^)
        echo To restart, first run: stop.bat
        pause
        exit /b 0
    ) else (
        del app.pid
    )
)

REM Start in new detached window
start /B "" venv\Scripts\python.exe main.py > log\app.log 2>&1

REM Get PID (Windows method)
timeout /t 2 /nobreak >nul
for /f "tokens=2" %%i in ('tasklist /FI "IMAGENAME eq python.exe" /FO LIST ^| find "PID:"') do (
    set "APP_PID=%%i"
    goto :found_pid
)
:found_pid

REM Verify process started
if defined APP_PID (
    echo !APP_PID! > app.pid
    echo [OK] Application started successfully!
    echo.
    echo ========================================
    echo Setup Complete!
    echo ========================================
    echo Process ID: !APP_PID!
    echo Log file: log\app.log
    echo API: http://localhost:8000
    echo.
    echo Useful commands:
    echo   stop.bat     - Stop the application
    echo   status.bat   - Check application status
    echo.
    echo Test endpoints:
    echo   curl http://localhost:8000
    echo   curl -X POST http://localhost:8000/greet
    echo ========================================
) else (
    echo [ERROR] Failed to start application
    echo Check log\app.log for errors
    pause
    exit /b 1
)

endlocal
