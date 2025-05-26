# PowerShell Profile for Windows Users
# This is the Windows equivalent of .zshrc
# Location: ~/Documents/PowerShell/Microsoft.PowerShell_profile.ps1

# Set PowerShell to UTF-8
[console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding

# Import Modules
Import-Module -Name Terminal-Icons -ErrorAction SilentlyContinue
Import-Module -Name posh-git -ErrorAction SilentlyContinue
Import-Module -Name PSReadLine -ErrorAction SilentlyContinue

# PSReadLine Configuration (similar to zsh-autosuggestions and zsh-syntax-highlighting)
if (Get-Module -Name PSReadLine) {
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle ListView
    Set-PSReadLineOption -EditMode Emacs
    Set-PSReadLineOption -HistorySearchCursorMovesToEnd
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
    Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function DeleteChar
    
    # Colors for syntax highlighting
    Set-PSReadLineOption -Colors @{
        Command            = 'Green'
        Parameter          = 'Gray'
        Operator           = 'Magenta'
        Variable           = 'Orange'
        String             = 'Yellow'
        Number             = 'White'
        Type               = 'Cyan'
        Comment            = 'DarkGray'
        InlinePrediction   = 'DarkGray'
        Default            = 'White'
    }
}

# Oh-My-Posh Configuration (Windows equivalent of Oh-My-Zsh)
# Install: winget install JanDeDobbeleer.OhMyPosh -s winget
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    # Use agnoster theme (same as in .zshrc)
    oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/agnoster.omp.json" | Invoke-Expression
    
    # Alternative themes you can try:
    # oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/powerlevel10k_rainbow.omp.json" | Invoke-Expression
    # oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/jandedobbeleer.omp.json" | Invoke-Expression
}

# Aliases (matching .zshrc aliases)
Set-Alias -Name vi -Value nvim
Set-Alias -Name vim -Value nvim
Set-Alias -Name lg -Value lazygit
Set-Alias -Name g -Value git
Set-Alias -Name python -Value python3 -ErrorAction SilentlyContinue

# Functions (equivalent to .zshrc aliases)
function zshconf { 
    if (Get-Command code -ErrorAction SilentlyContinue) {
        code $PROFILE 
    } else {
        notepad $PROFILE
    }
}

function zshsrc { 
    . $PROFILE 
    Write-Host "PowerShell profile reloaded!" -ForegroundColor Green
}

# Git shortcuts (matching oh-my-zsh git plugin)
function gs { git status }
function ga { git add $args }
function gc { git commit $args }
function gp { git push }
function gpl { git pull }
function gco { git checkout $args }
function gb { git branch $args }
function gd { git diff $args }
function gl { git log --oneline --graph --decorate }

# Docker/Podman alias (if using podman as docker replacement)
if (Get-Command podman -ErrorAction SilentlyContinue) {
    Set-Alias -Name docker -Value podman
}

# Environment Variables
$env:EDITOR = "nvim"

# Add custom paths (Windows equivalent of PATH exports)
# Scoop apps
if (Test-Path "$env:USERPROFILE\scoop\apps") {
    $env:PATH = "$env:USERPROFILE\scoop\shims;$env:PATH"
}

# Go environment (matching .zshrc)
if (Test-Path "$env:USERPROFILE\go") {
    $env:GOPATH = "$env:USERPROFILE\go"
    $env:PATH = "$env:GOPATH\bin;$env:PATH"
}

# NVM for Windows (different from Unix nvm)
# Install: scoop install nvm
# or: winget install CoreyButler.NVMforWindows
if (Get-Command nvm -ErrorAction SilentlyContinue) {
    # NVM for Windows works differently, no need to source scripts
    # Just ensure it's in PATH
}

# Load custom environment variables from file (like .env_vars in .zshrc)
$envFile = "$env:USERPROFILE\.env_vars.ps1"
if (Test-Path $envFile) {
    . $envFile
}

# Utilities
function which($name) {
    Get-Command $name -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Definition
}

function touch($file) {
    if (Test-Path $file) {
        (Get-Item $file).LastWriteTime = Get-Date
    } else {
        New-Item -ItemType File -Path $file
    }
}

# Better ls (using Terminal-Icons)
if (Get-Module -Name Terminal-Icons) {
    function ll { Get-ChildItem -Force | Format-Table -AutoSize }
    function la { Get-ChildItem -Force }
} else {
    function ll { Get-ChildItem | Format-Table -AutoSize }
    function la { Get-ChildItem -Force }
}

# Welcome message
$psVersion = $PSVersionTable.PSVersion.ToString()
Write-Host "Welcome to PowerShell $psVersion" -ForegroundColor Green
Write-Host "Neovim dotfiles loaded. Run 'nvim' to start editing!" -ForegroundColor Cyan
Write-Host ""

# Show tips for Windows users
if (-not (Test-Path "$env:USERPROFILE\.dotfiles_tips_shown")) {
    Write-Host "💡 Tips for Windows users:" -ForegroundColor Yellow
    Write-Host "  - Install Windows Terminal for better experience: winget install Microsoft.WindowsTerminal" -ForegroundColor Gray
    Write-Host "  - Set a Nerd Font in Windows Terminal settings for icons" -ForegroundColor Gray
    Write-Host "  - Run 'zshconf' to edit this profile" -ForegroundColor Gray
    Write-Host "  - Run 'zshsrc' to reload this profile" -ForegroundColor Gray
    Write-Host ""
    
    # Create marker file so tips only show once
    New-Item -ItemType File -Path "$env:USERPROFILE\.dotfiles_tips_shown" -Force | Out-Null
}

# Chocolatey profile (if installed)
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
    Import-Module "$ChocolateyProfile"
}
