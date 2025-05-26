# Windows Setup Guide

This guide provides detailed instructions for Windows users to set up the dotfiles.

## Prerequisites

1. **Windows 10/11** with latest updates
2. **PowerShell 5.1+** or **PowerShell Core 7+**
3. **Administrator privileges** (for creating symlinks)

## Recommended Software

### Windows Terminal
The best terminal experience on Windows:
```powershell
winget install Microsoft.WindowsTerminal
```

### PowerShell Core
For cross-platform compatibility:
```powershell
winget install Microsoft.PowerShell
```

## Installation Steps

### 1. Clone the Repository
```powershell
git clone https://github.com/gyeonghokim/dotfiles.git
cd dotfiles
```

### 2. Run the Installer

#### Option A: PowerShell Script (Recommended)
```powershell
# Allow script execution
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Run the installer
./install.ps1
```

#### Option B: Batch File
```cmd
install.bat
```

### 3. Select Windows in the Installer
The installer will show a menu - select "Windows" and it will:
- Install a package manager (Scoop/Chocolatey/Winget)
- Install Neovim and development tools
- Set up PowerShell profile with Oh-My-Posh
- Configure Neovim with LazyVim

## Post-Installation Configuration

### 1. Configure Windows Terminal

Add Hack Nerd Font:
1. Open Windows Terminal Settings (Ctrl+,)
2. Go to Profiles → Defaults
3. Under Appearance, set Font face to "Hack Nerd Font"
4. Save settings

### 2. Set Color Scheme

Recommended color schemes for Windows Terminal:
- One Half Dark
- Dracula
- Nord
- Tokyo Night

### 3. Enable Oh-My-Posh Themes

Edit your PowerShell profile:
```powershell
notepad $PROFILE
```

Change the theme by modifying this line:
```powershell
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/agnoster.omp.json"
```

Available themes:
- `agnoster` - Classic theme with git info
- `powerlevel10k_rainbow` - Colorful and informative
- `jandedobbeleer` - Clean and minimal
- `material` - Material design inspired

### 4. Install Additional PowerShell Modules

```powershell
# Package management
Install-Module -Name PowerShellGet -Force

# Better command history
Install-Module -Name PSReadLine -Force

# Git integration
Install-Module -Name posh-git -Force

# Terminal icons
Install-Module -Name Terminal-Icons -Force

# Fuzzy finder
Install-Module -Name PSFzf -Force
```

## Package Managers

### Scoop (Recommended)
```powershell
# Install
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression

# Add buckets for more packages
scoop bucket add extras
scoop bucket add nerd-fonts
```

### Chocolatey
```powershell
# Install (Admin PowerShell)
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

### Winget
Usually pre-installed on Windows 11. For Windows 10:
```powershell
# Install from Microsoft Store
# Search for "App Installer"
```

## Neovim on Windows

### File Paths
- Config location: `~/AppData/Local/nvim/`
- Data location: `~/AppData/Local/nvim-data/`

### Common Issues

**Issue**: Treesitter compilation errors
**Solution**: Install Visual Studio Build Tools
```powershell
winget install Microsoft.VisualStudio.2022.BuildTools
```

**Issue**: Mason.nvim can't install LSPs
**Solution**: Ensure you have:
- Git in PATH
- Node.js installed
- Python installed

### Windows-Specific Neovim Settings

Create `~/AppData/Local/nvim/lua/config/windows.lua`:
```lua
-- Windows-specific settings
if vim.fn.has("win32") == 1 then
  -- Use PowerShell
  vim.opt.shell = "pwsh.exe"
  vim.opt.shellcmdflag = "-NoLogo -ExecutionPolicy RemoteSigned -Command"
  vim.opt.shellquote = ""
  vim.opt.shellxquote = ""
  
  -- Fix paths
  vim.opt.shellslash = true
  vim.opt.shellredir = "2>&1 | Out-File -Encoding UTF8 %s"
end
```

## Git Configuration

Configure Git for Windows:
```powershell
# Set core editor
git config --global core.editor "nvim"

# Handle line endings
git config --global core.autocrlf true

# Enable long paths
git config --global core.longpaths true

# Credential manager
git config --global credential.helper manager
```

## Environment Variables

Create `~/.env_vars.ps1` for machine-specific variables:
```powershell
# Example content
$env:DEVELOPMENT_SERVER = "localhost:3000"
$env:API_KEY = "your-api-key"
```

## Aliases and Functions

The PowerShell profile includes many aliases matching the Unix setup:

| Unix | Windows PowerShell | Description |
|------|-------------------|-------------|
| `ls -la` | `la` | List all files |
| `ls -l` | `ll` | List files with details |
| `which` | `which` | Find command location |
| `touch` | `touch` | Create empty file |
| `source ~/.zshrc` | `zshsrc` | Reload profile |
| `code ~/.zshrc` | `zshconf` | Edit profile |

## WSL Integration

If using WSL (Windows Subsystem for Linux):

1. Install WSL:
```powershell
wsl --install
```

2. Use Unix installation in WSL:
```bash
# Inside WSL
cd /mnt/c/Users/YOUR_USERNAME/dotfiles
./install
```

3. Share Neovim config between Windows and WSL:
```bash
# In WSL
ln -s /mnt/c/Users/YOUR_USERNAME/AppData/Local/nvim ~/.config/nvim
```

## Troubleshooting

### PowerShell Execution Policy
```powershell
# Check current policy
Get-ExecutionPolicy

# Set for current user
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Symlink Issues
Run PowerShell as Administrator or enable Developer Mode:
1. Settings → Update & Security → For developers
2. Enable "Developer Mode"

### Font Issues
1. Download from [nerdfonts.com](https://www.nerdfonts.com/)
2. Install for all users
3. Restart Windows Terminal

### Path Issues
Add to PATH in PowerShell:
```powershell
$env:PATH += ";C:\your\new\path"
[Environment]::SetEnvironmentVariable("PATH", $env:PATH, [EnvironmentVariableTarget]::User)
```

## Additional Resources

- [Windows Terminal Documentation](https://docs.microsoft.com/en-us/windows/terminal/)
- [PowerShell Documentation](https://docs.microsoft.com/en-us/powershell/)
- [Oh-My-Posh Themes](https://ohmyposh.dev/docs/themes)
- [Scoop](https://scoop.sh/)
- [Neovim Windows Wiki](https://github.com/neovim/neovim/wiki/Building-Neovim#windows)
