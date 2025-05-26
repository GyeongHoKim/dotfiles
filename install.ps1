#!/usr/bin/env pwsh
# PowerShell Core script for dotfiles installation (cross-platform)

Write-Host "========================================"
Write-Host " Dotfiles Installer"
Write-Host "========================================"
Write-Host ""

# Check if Go is installed
if (-not (Get-Command go -ErrorAction SilentlyContinue)) {
    Write-Host "Error: Go is not installed or not in PATH." -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install Go first:" -ForegroundColor Yellow
    Write-Host "  1. Download from https://golang.org/dl/"
    Write-Host "  2. Or use a package manager:"
    Write-Host "     - Scoop: scoop install go"
    Write-Host "     - Chocolatey: choco install golang"
    Write-Host "     - Winget: winget install GoLang.Go"
    Write-Host "     - macOS: brew install go"
    Write-Host "     - Linux: sudo apt install golang-go"
    Write-Host ""
    exit 1
}

# Navigate to the installer directory
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location "$scriptPath/cmd"

# Download dependencies
Write-Host "Downloading Go dependencies..." -ForegroundColor Cyan
go mod download

# Build the installer
Write-Host "Building installer..." -ForegroundColor Cyan
$output = if ($IsWindows) { "dotfiles-installer.exe" } else { "dotfiles-installer" }
go build -o $output install.go

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "Error: Failed to build the installer." -ForegroundColor Red
    exit 1
}

# Make executable on Unix systems
if (-not $IsWindows) {
    chmod +x $output
}

# Run the installer
Write-Host ""
Write-Host "Starting the installer..." -ForegroundColor Green
Write-Host ""

if ($IsWindows) {
    .\dotfiles-installer.exe
} else {
    ./dotfiles-installer
}

# Cleanup
Remove-Item $output -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "Installation process completed!" -ForegroundColor Green
