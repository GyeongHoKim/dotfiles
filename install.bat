@echo off
REM Windows Batch script for dotfiles installation
REM This is a simple wrapper that compiles and runs the Go installer

echo ========================================
echo  Dotfiles Installer for Windows
echo ========================================
echo.

REM Check if Go is installed
where go >nul 2>nul
if %errorlevel% neq 0 (
    echo Error: Go is not installed or not in PATH.
    echo.
    echo Please install Go first:
    echo   1. Download from https://golang.org/dl/
    echo   2. Or use a package manager:
    echo      - Scoop: scoop install go
    echo      - Chocolatey: choco install golang
    echo      - Winget: winget install GoLang.Go
    echo.
    pause
    exit /b 1
)

REM Navigate to the installer directory
cd /d "%~dp0\cmd"

REM Download dependencies
echo Downloading Go dependencies...
go mod download

REM Build the installer
echo Building installer...
go build -o dotfiles-installer.exe install.go

if %errorlevel% neq 0 (
    echo.
    echo Error: Failed to build the installer.
    pause
    exit /b 1
)

REM Run the installer
echo.
echo Starting the installer...
echo.
dotfiles-installer.exe

REM Cleanup
del dotfiles-installer.exe >nul 2>nul

echo.
echo Installation process completed!
pause
