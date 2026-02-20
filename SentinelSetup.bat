@echo off
title Sentinel Setup
echo.
echo ╔═══════════════════════════════════════════════════════════╗
echo ║                  Sentinel Setup                           ║
echo ╚═══════════════════════════════════════════════════════════╝
echo.

REM Check for Python
python --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Python not found!
    echo.
    echo Please install Python 3.8 or later from:
    echo https://www.python.org/downloads/
    echo.
    echo Make sure to check "Add Python to PATH" during installation!
    echo.
    pause
    exit /b 1
)

echo Python found. Starting setup wizard...
echo.

REM Run PowerShell setup
powershell -ExecutionPolicy Bypass -File "%~dp0setup_windows.ps1"

if errorlevel 1 (
    echo.
    echo [ERROR] Setup failed. Please check the error messages above.
    echo.
    pause
    exit /b 1
)

echo.
echo Setup complete!
pause
