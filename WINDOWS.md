# Windows 11 Setup Guide

This guide will help you set up the same web development environment on Windows 11 using this dotfiles repository.

## Prerequisites

- **Windows 11** (required for native winget support)
- **PowerShell 5.1+** (built into Windows 11)
- **Administrator access** (for initial setup)

## Quick Start

### 1. Install Chezmoi

Open PowerShell as Administrator and run:

```powershell
# Install chezmoi via winget
winget install twpayne.chezmoi

# Restart your PowerShell session to update PATH
```

### 2. Initialize Dotfiles

Replace `<your-github-username>` with your GitHub username:

```powershell
chezmoi init https://github.com/<your-github-username>/dotfiles.git
```

Or if you've cloned this repository already:

```powershell
chezmoi init /path/to/your/dotfiles
```

### 3. Apply Configuration

```powershell
# Preview what will be installed
chezmoi diff

# Apply the configuration (installs packages and sets up environment)
chezmoi apply
```

This will:
- Install development tools via winget
- Set up PowerShell profile with mise activation
- Deploy Neovim configuration
- Install mise for language version management

### 4. Post-Installation

After the installation completes:

1. **Restart your terminal** to load the new PATH entries
2. **Install language runtimes**:
   ```powershell
   mise install
   ```


## What Gets Installed

### Core Development Tools (via winget)

- **Version Control**: Git, GitHub CLI
- **Editors**: Vim, VS Code
- **Terminal**: Windows Terminal, PowerShell 7+
- **Containers**: Docker Desktop
- **Infrastructure**: kubectl, helm, terraform, pulumi, flyctl, doctl
- **CLI Utilities**: ripgrep, fd, fzf, helix, lazygit, zoxide, Task
- **Browsers**: Firefox, Brave
- **Productivity**: Obsidian, GIMP, VLC, OBS Studio, Insomnia

### Language Runtimes (via mise)

- Node.js (LTS)
- Python (latest)
- Go (latest)
- Rust (latest)

These are managed by mise for version flexibility. You can override versions per-project.

## PowerShell Profile Features

The installed PowerShell profile provides:

### Aliases

```powershell
v          # nvim
k          # kubectl
task       # go-task
```

### Git Shortcuts

```powershell
gs         # git status
ga         # git add
gc         # git commit
gp         # git push
gl         # git pull
gd         # git diff
gco        # git checkout
gb         # git branch
```

### Utility Functions

```powershell
which <command>    # Find command path
touch <file>       # Create or update file timestamp
docker-clean       # Clean Docker containers, images, volumes
..                 # Go up one directory
...                # Go up two directories
....               # Go up three directories
```

### mise Integration

The profile automatically activates mise, giving you access to:

```powershell
mise current       # Show active versions
mise install       # Install configured tools
mise use node@20   # Use specific Node.js version
mise use -g go@1.22  # Set global Go version
```

## Optional Enhancements

Install these PowerShell modules for enhanced experience:

```powershell
# Git integration with branch info in prompt
Install-Module posh-git -Scope CurrentUser

# File/folder icons in directory listings
Install-Module Terminal-Icons -Scope CurrentUser

# Better command line editing (already included in PowerShell 7+)
Install-Module PSReadLine -Scope CurrentUser -Force
```

After installing, restart your PowerShell session. The profile will automatically import these modules.

## Common Tasks

### Update All Packages

```powershell
# Update winget packages
winget upgrade --all

# Update mise-managed tools
mise upgrade

# Update PowerShell modules
Update-Module
```

### Add a New Tool

#### System Package (via winget)

1. Find the package ID:
   ```powershell
   winget search <tool-name>
   ```

2. Edit the installation script:
   ```powershell
   chezmoi edit ~/run_once_install_packages_windows.ps1
   ```

3. Add to the `$packages` hashtable:
   ```powershell
   "PackageId.Here" = "Display Name"
   ```

4. Apply changes:
   ```powershell
   chezmoi apply
   ```

#### Language Runtime (via mise)

```powershell
# Add to current project
mise use node@20

# Add globally
mise use -g python@3.11

# Or edit global config
chezmoi edit ~/.config/mise/config.toml
```

### Manage Dotfiles

```powershell
# Add a new file to dotfiles
chezmoi add ~/.gitconfig

# Edit a managed file
chezmoi edit ~/.config/nvim/init.lua

# See what changed
chezmoi diff

# Apply all changes
chezmoi apply

# Re-run initialization scripts
chezmoi state delete-bucket --bucket=scriptState
chezmoi apply
```

## Neovim Setup

The Neovim configuration is shared with Linux/macOS but uses a different path on Windows.

### Windows-Specific Path

According to [LazyVim's official documentation](https://www.lazyvim.org/installation), Windows uses:
- **Windows**: `$env:LOCALAPPDATA\nvim` (typically `C:\Users\<username>\AppData\Local\nvim`)
- **Linux/macOS**: `~/.config/nvim`

The setup script automatically moves the configuration from `~/.config/nvim` to `$env:LOCALAPPDATA\nvim` during installation to ensure proper functionality on Windows.

### First Launch

On first launch, Neovim will:
1. Install Lazy.nvim (plugin manager)
2. Download and install all plugins
3. Set up LSP servers

This may take a minute. Be patient!



## Troubleshooting

### winget not found

Ensure you're on Windows 11 or install [App Installer](https://www.microsoft.com/p/app-installer/9nblggh4nns1) from Microsoft Store.

### mise not found after installation

Restart your PowerShell session or run:
```powershell
. $PROFILE
```

### Docker Desktop requires WSL2

If Docker Desktop installation fails or doesn't start:
1. Install WSL2: `wsl --install`
2. Restart your computer
3. Launch Docker Desktop

### Execution Policy Error

If you get "execution policy" errors:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```



## Differences from Linux/macOS

- **No Ansible**: Uses PowerShell scripts instead
- **No Oh My Zsh**: PowerShell with custom profile
- **Path separators**: `\` instead of `/`
- **Line endings**: CRLF by default (configure Git to handle this)
- **Case-insensitive**: File system is case-insensitive
- **Docker**: Requires Docker Desktop (includes WSL2 backend)

## Git Configuration for Windows

Recommended Git settings for Windows:

```powershell
# Handle line endings automatically
git config --global core.autocrlf true

# Use Windows credential manager
git config --global credential.helper manager

# Set default editor
git config --global core.editor "nvim"
```

## Further Customization

### Modify PowerShell Profile

```powershell
chezmoi edit ~/Documents/PowerShell/Microsoft.PowerShell_profile.ps1
chezmoi apply
```

### Modify Package List

```powershell
chezmoi edit ~/run_once_install_packages_windows.ps1
chezmoi state delete-bucket --bucket=scriptState
chezmoi apply
```

### Modify mise Configuration

```powershell
chezmoi edit ~/.config/mise/config.toml
chezmoi apply
mise install
```

## Getting Help

- Chezmoi docs: https://chezmoi.io
- mise docs: https://mise.jdx.dev
- PowerShell docs: https://docs.microsoft.com/powershell


## Uninstallation

To completely remove the setup:

```powershell
# Remove managed files (WARNING: This removes all dotfiles)
chezmoi purge

# Uninstall mise-managed tools
mise uninstall --all



# Optionally uninstall packages via winget
winget uninstall <package-id>
```
