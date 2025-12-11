# PowerShell Profile for Development Environment
# This file is managed by chezmoi

# Environment Variables
$env:EDITOR = "nvim"

# Add custom paths to PATH
$pathsToAdd = @(
    "$env:USERPROFILE\.local\share\bob\nvim-bin",  # bob-nvim managed Neovim
    "$env:USERPROFILE\bin",                         # User binaries
    "$env:USERPROFILE\.cargo\bin",                  # Rust/Cargo binaries
    "$env:USERPROFILE\.scripts\bin"                 # Custom scripts
)

foreach ($path in $pathsToAdd) {
    if (Test-Path $path) {
        $env:PATH = "$path;$env:PATH"
    }
}

# Initialize mise (version manager for Node, Python, Go, Rust)
if (Get-Command mise -ErrorAction SilentlyContinue) {
    mise activate pwsh | Out-String | Invoke-Expression
}

# Initialize Oh My Posh
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\paradox.omp.json" | Invoke-Expression
}

# Aliases (matching Linux/macOS setup)
Set-Alias -Name task -Value go-task -ErrorAction SilentlyContinue
Set-Alias -Name v -Value nvim -ErrorAction SilentlyContinue
Set-Alias -Name k -Value kubectl -ErrorAction SilentlyContinue

# Git aliases (common shortcuts)
function gs { git status }
function ga { git add $args }
function gc { git commit $args }
function gp { git push $args }
function gl { git pull $args }
function gd { git diff $args }
function gco { git checkout $args }
function gb { git branch $args }

# Utility functions
function which($command) {
    Get-Command -Name $command -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}

function touch($file) {
    if (Test-Path $file) {
        (Get-Item $file).LastWriteTime = Get-Date
    }
    else {
        New-Item -ItemType File -Path $file | Out-Null
    }
}

# Docker helper functions
function docker-clean {
    Write-Host "Removing stopped containers..." -ForegroundColor Yellow
    docker container prune -f
    Write-Host "Removing unused images..." -ForegroundColor Yellow
    docker image prune -a -f
    Write-Host "Removing unused volumes..." -ForegroundColor Yellow
    docker volume prune -f
    Write-Host "Docker cleanup complete!" -ForegroundColor Green
}

# Directory navigation helpers
function .. { Set-Location .. }
function ... { Set-Location ..\.. }
function .... { Set-Location ..\..\.. }

# Enhanced prompt with Git status (if posh-git is installed)
if (Get-Module -ListAvailable -Name posh-git) {
    Import-Module posh-git
}
else {
    Write-Host "Tip: Install posh-git for enhanced Git integration: Install-Module posh-git -Scope CurrentUser" -ForegroundColor Yellow
}

# Optional: Terminal Icons (if installed)
if (Get-Module -ListAvailable -Name Terminal-Icons) {
    Import-Module Terminal-Icons
}

# Optional: PSReadLine configuration for better command line editing
if (Get-Module -ListAvailable -Name PSReadLine) {
    Import-Module PSReadLine
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle ListView
    Set-PSReadLineOption -EditMode Windows
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
}

# Welcome message
Write-Host "PowerShell development environment loaded" -ForegroundColor Green
Write-Host "Run 'mise current' to see active tool versions" -ForegroundColor Cyan
