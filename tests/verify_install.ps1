# Verification script for dotfiles installation on Windows
# This script checks if essential tools are installed correctly

$ErrorActionPreference = "Continue"

$script:Passed = 0
$script:Failed = 0
$script:Skipped = 0

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

function Write-Skip {
    param([string]$Message)
    Write-Host "[SKIP] $Message" -ForegroundColor Yellow
    $script:Skipped++
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

function Test-CommandOptional {
    param(
        [string]$Command,
        [string]$Description
    )

    $result = Get-Command $Command -ErrorAction SilentlyContinue
    if ($result) {
        Write-Pass "$Description ($Command)"
    } else {
        Write-Skip "$Description ($Command) - optional"
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

function Test-MiseTool {
    param(
        [string]$Tool,
        [string]$Description
    )

    $mise = Get-Command "mise" -ErrorAction SilentlyContinue
    if (-not $mise) {
        Write-Skip "$Description - mise not available"
        return
    }

    $miseList = & mise list 2>$null
    if ($miseList -match $Tool) {
        Write-Pass "$Description (mise: $Tool)"
    } elseif (Get-Command $Tool -ErrorAction SilentlyContinue) {
        Write-Pass "$Description ($Tool via PATH)"
    } else {
        Write-Fail "$Description ($Tool)"
    }
}

function Test-Rust {
    $rustcPath = "$env:USERPROFILE\.cargo\bin\rustc.exe"
    $cargoPath = "$env:USERPROFILE\.cargo\bin\cargo.exe"

    if ((Test-Path $rustcPath) -or (Get-Command "rustc" -ErrorAction SilentlyContinue)) {
        try {
            $version = & rustc --version 2>$null
            Write-Pass "Rust compiler ($version)"
        } catch {
            Write-Pass "Rust compiler (rustc)"
        }
    } else {
        Write-Fail "Rust compiler (rustc)"
    }

    if ((Test-Path $cargoPath) -or (Get-Command "cargo" -ErrorAction SilentlyContinue)) {
        Write-Pass "Cargo package manager"
    } else {
        Write-Fail "Cargo package manager"
    }
}

Write-Host "============================================"
Write-Host "Dotfiles Installation Verification (Windows)"
Write-Host "============================================"
Write-Host ""

# ===== CORE TOOLS =====
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
Test-Command "codium" "VSCodium"
Test-Path-Exists "$env:LOCALAPPDATA\nvim" "Neovim config directory"

Write-Host ""
Write-Host "--- CLI Development Tools ---"
Test-Command "rg" "Ripgrep"
Test-Command "fzf" "FZF"
Test-Command "fd" "fd-find"
Test-CommandOptional "lazygit" "Lazygit"

Write-Host ""
Write-Host "--- Build Tools ---"
Test-CommandOptional "gcc" "GCC"
Test-CommandOptional "make" "Make"

# ===== LANGUAGE RUNTIMES =====
Write-Host ""
Write-Host "--- Rust Toolchain ---"
Test-Rust

Write-Host ""
Write-Host "--- Language Runtimes (via mise) ---"
Test-MiseTool "node" "Node.js"
Test-MiseTool "python" "Python"
Test-MiseTool "go" "Go"

# ===== INFRASTRUCTURE =====
Write-Host ""
Write-Host "--- Container & Infrastructure ---"
Test-CommandOptional "docker" "Docker"
Test-CommandOptional "kubectl" "kubectl"

# ===== FONTS =====
Write-Host ""
Write-Host "--- Fonts ---"
$fontPath = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts\JetBrainsMono*"
$systemFontPath = "C:\Windows\Fonts\JetBrainsMono*"

if ((Get-ChildItem $fontPath -ErrorAction SilentlyContinue) -or
    (Get-ChildItem $systemFontPath -ErrorAction SilentlyContinue)) {
    Write-Pass "JetBrains Mono Nerd Font"
} else {
    Write-Fail "JetBrains Mono Nerd Font"
}

# ===== SUMMARY =====
Write-Host ""
Write-Host "============================================"
Write-Host "Results Summary"
Write-Host "============================================"
Write-Host "  Passed:  $script:Passed" -ForegroundColor Green
Write-Host "  Failed:  $script:Failed" -ForegroundColor Red
Write-Host "  Skipped: $script:Skipped" -ForegroundColor Yellow
Write-Host "============================================"

if ($script:Failed -gt 0) {
    Write-Host "Some checks failed!" -ForegroundColor Red
    exit 1
} else {
    Write-Host "All required checks passed!" -ForegroundColor Green
    exit 0
}
