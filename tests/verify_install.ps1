# Verification script for dotfiles installation on Windows
# This script checks if essential tools are installed correctly

$ErrorActionPreference = "Continue"

$script:Passed = 0
$script:Failed = 0

function Write-Pass {
    param([string]$Message)
    Write-Host "[PASS] $Message" -ForegroundColor Green
    $script:Passed++
}

function Write-Fail {
    param([string]$Message)
    Write-Host "[FAIL] $Message" -ForegroundColor Red
    $script:Failed++
}

function Test-Command {
    param(
        [string]$Command,
        [string]$Description
    )

    $result = Get-Command $Command -ErrorAction SilentlyContinue
    if ($result) {
        Write-Pass "$Description ($Command)"
    } else {
        Write-Fail "$Description ($Command)"
    }
}

function Test-Path-Exists {
    param(
        [string]$Path,
        [string]$Description
    )

    if (Test-Path $Path) {
        Write-Pass "$Description ($Path)"
    } else {
        Write-Fail "$Description ($Path)"
    }
}

Write-Host "============================================"
Write-Host "Dotfiles Installation Verification (Windows)"
Write-Host "============================================"
Write-Host ""

Write-Host "--- Package Manager Tools ---"
Test-Command "mise" "mise version manager"
Test-Command "git" "Git"
Test-Command "gh" "GitHub CLI"
Test-Command "winget" "Windows Package Manager"

Write-Host ""
Write-Host "--- Shell ---"
Test-Command "pwsh" "PowerShell Core"
Test-Path-Exists "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1" "PowerShell profile"

Write-Host ""
Write-Host "--- Editors ---"
Test-Command "nvim" "Neovim"
Test-Command "code" "VS Code"
Test-Path-Exists "$env:LOCALAPPDATA\nvim" "Neovim config directory"

Write-Host ""
Write-Host "--- CLI Development Tools ---"
Test-Command "rg" "Ripgrep"
Test-Command "fzf" "FZF"
Test-Command "fd" "fd-find"

Write-Host ""
Write-Host "--- Container & Infrastructure ---"
Test-Command "docker" "Docker"
Test-Command "kubectl" "kubectl"

Write-Host ""
Write-Host "--- Additional Tools ---"
Test-Command "lazygit" "Lazygit"

Write-Host ""
Write-Host "============================================"
Write-Host "Results: $script:Passed passed, $script:Failed failed"
Write-Host "============================================"

if ($script:Failed -gt 0) {
    Write-Host "Some checks failed!" -ForegroundColor Red
    exit 1
} else {
    Write-Host "All checks passed!" -ForegroundColor Green
    exit 0
}
