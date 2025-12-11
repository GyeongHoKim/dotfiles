# Windows Package Installation Script
# This script installs development tools using winget (Windows Package Manager)
# It runs once during initial setup

$ErrorActionPreference = "Stop"

Write-Host "Starting Windows package installation..." -ForegroundColor Green

# Function to check if winget is available
function Test-WingetAvailable {
    try {
        $null = winget --version
        return $true
    }
    catch {
        return $false
    }
}

# Function to install a package with winget
function Install-WingetPackage {
    param(
        [string]$PackageId,
        [string]$Name
    )

    Write-Host "Installing $Name..." -ForegroundColor Cyan
    try {
        winget install --id $PackageId --silent --accept-package-agreements --accept-source-agreements
        Write-Host "  ✓ $Name installed successfully" -ForegroundColor Green
    }
    catch {
        Write-Host "  ✗ Failed to install $Name" -ForegroundColor Red
        Write-Host "    Error: $_" -ForegroundColor Red
    }
}

# Check if winget is available
if (-not (Test-WingetAvailable)) {
    Write-Host "Error: winget is not available. Please ensure you're running Windows 11 or install App Installer from the Microsoft Store." -ForegroundColor Red
    exit 1
}

Write-Host "winget is available. Proceeding with installation..." -ForegroundColor Green

# Core development tools
$packages = @{
    # Version Control & CLI Tools
    "Git.Git" = "Git"
    "GitHub.cli" = "GitHub CLI"

    # Editors
    "vim.vim" = "Vim"
    "Microsoft.VisualStudioCode" = "Visual Studio Code"

    # Terminal & Shell Tools
    "Microsoft.WindowsTerminal" = "Windows Terminal"
    "Microsoft.PowerShell" = "PowerShell 7+"
    "junegunn.fzf" = "fzf"

    # Container Tools
    "Docker.DockerDesktop" = "Docker Desktop"

    # Infrastructure & Cloud Tools
    "Kubernetes.kubectl" = "kubectl"
    "Hashicorp.Terraform" = "Terraform"
    "Pulumi.Pulumi" = "Pulumi"
    "Helm.Helm" = "Helm"
    "Flyio.flyctl" = "flyctl"
    "DigitalOcean.doctl" = "doctl"

    # Build Tools
    "GoTask.Task" = "Task"
    "OpenJS.NodeJS.LTS" = "Node.js LTS"

    # Utilities
    "BurntSushi.ripgrep.MSVC" = "ripgrep"
    "sharkdp.fd" = "fd"
    "tmux.tmux" = "tmux"
    "ajeetdsouza.zoxide" = "zoxide"
    "junegunn.helix" = "Helix"
    "JesseDuffield.lazygit" = "lazygit"

    # GUI Applications
    "Mozilla.Firefox" = "Firefox"
    "Brave.Brave" = "Brave Browser"
    "Obsidian.Obsidian" = "Obsidian"
    "GIMP.GIMP" = "GIMP"
    "VideoLAN.VLC" = "VLC"
    "OBSProject.OBSStudio" = "OBS Studio"
    "Insomnia.Insomnia" = "Insomnia"
}

# Install packages
$totalPackages = $packages.Count
$currentPackage = 0

foreach ($package in $packages.GetEnumerator()) {
    $currentPackage++
    Write-Host "`n[$currentPackage/$totalPackages]" -ForegroundColor Yellow
    Install-WingetPackage -PackageId $package.Key -Name $package.Value
}

# Install mise (version manager for Node, Python, Go, Rust)
Write-Host "`nInstalling mise..." -ForegroundColor Cyan
try {
    # Download and install mise for Windows
    $miseInstaller = "$env:TEMP\mise-installer.ps1"
    Invoke-WebRequest -Uri "https://mise.jdx.dev/install.ps1" -OutFile $miseInstaller
    & $miseInstaller
    Write-Host "  ✓ mise installed successfully" -ForegroundColor Green
    Write-Host "  Note: You may need to restart your terminal for mise to be available" -ForegroundColor Yellow
}
catch {
    Write-Host "  ✗ Failed to install mise" -ForegroundColor Red
    Write-Host "    Error: $_" -ForegroundColor Red
}

# Install bob-nvim (Neovim version manager)
Write-Host "`nInstalling bob-nvim..." -ForegroundColor Cyan
try {
    # Check if Rust/Cargo is available (needed for bob)
    if (Get-Command cargo -ErrorAction SilentlyContinue) {
        cargo install --git https://github.com/MordechaiHadad/bob.git
        Write-Host "  ✓ bob-nvim installed successfully" -ForegroundColor Green
    }
    else {
        Write-Host "  ! Cargo not found. bob-nvim installation skipped." -ForegroundColor Yellow
        Write-Host "    Run 'mise install rust' after setup, then install bob with:" -ForegroundColor Yellow
        Write-Host "    cargo install --git https://github.com/MordechaiHadad/bob.git" -ForegroundColor Yellow
    }
}
catch {
    Write-Host "  ✗ Failed to install bob-nvim" -ForegroundColor Red
    Write-Host "    Error: $_" -ForegroundColor Red
}

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "Package installation complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Restart your terminal to load new PATH entries" -ForegroundColor White
Write-Host "2. Run 'mise doctor' to verify mise installation" -ForegroundColor White
Write-Host "3. Run 'mise install' to install language runtimes (Node, Python, Go, Rust)" -ForegroundColor White
Write-Host "4. If you haven't already, install bob-nvim after Rust is available" -ForegroundColor White
Write-Host ""
