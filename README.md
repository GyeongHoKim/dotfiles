# dotfiles

This repo contains the configuration to setup my machines for web development. This is using [Chezmoi](https://chezmoi.io), the dotfile manager to setup the install.

Supported platforms: **Fedora**, **Debian/Ubuntu**, **macOS**, and **Windows 11**

```shell
export GITHUB_USERNAME=GyeongHoKim
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply $GITHUB_USERNAME
```

Windows11:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
$env:GITHUB_USERNAME = "GyeongHoKim"
& ([scriptblock]::Create((irm 'https://get.chezmoi.io/ps1'))) init --apply $env:GITHUB_USERNAME
```

## What gets installed

### All Platforms (Linux + macOS)

**Shell & Terminal:**

- zsh with [Oh My Zsh](https://ohmyz.sh/)
- tmux for terminal multiplexing
- JetBrains Mono Nerd Font

**Editors:**

- Neovim (configured with LazyVim)

**Language Runtimes** (via [mise](https://mise.jdx.dev)):

- Node.js (LTS)
- Python (latest stable)
- Go (latest stable)
- Rust (latest stable)

> **Note:** Versions are set to "latest" so each new machine setup installs the current stable versions at that time.

**CLI Development Tools:**

- Git + GitHub CLI (`gh`)
- Search: `ripgrep`, `fzf`, `fd-find`
- Build tools: gcc, make, autoconf
- Package managers: poetry (Python), luarocks (Lua)
- Task runner: go-task
- lazygit

**Infrastructure Tools:**

- kubectl, helm
- terraform, pulumi

### Linux Only (Fedora + Debian/Ubuntu)

**System:**

- Docker (docker-ce)
- GNOME Tweaks
- inotify-tools
- flatpak
- podman-compose

**GUI Applications (via Flatpak):**

- OBS Studio
- VLC Media Player
- Tenacity (audio editor)
- Obsidian (note-taking)
- GIMP (image editor)
- Insomnia (API testing)
- Foliate (ebook reader)
- Meld (diff/merge tool)
- DB Browser for SQLite

**Native Packages:**

- VSCodium
- Brave Browser
- Blender (3D graphics)

### macOS Only

**System:**

- Docker Desktop
- fswatch (file watcher)

**GUI Applications (via Homebrew Cask):**

- VSCodium
- Brave Browser
- Blender
- OBS Studio
- VLC Media Player
- Obsidian
- GIMP
- Insomnia
- Meld
- DB Browser for SQLite

### Windows 11

**Shell & Terminal:**

- PowerShell 7+ with custom profile
- Windows Terminal

**Editors:**

- Neovim
- VSCodium
- Vim, Helix

**CLI Tools (via winget):**

- Git, GitHub CLI
- ripgrep, fzf, fd, lazygit, zoxide
- Task (go-task)

**Infrastructure Tools:**

- Docker Desktop
- kubectl, helm
- terraform, pulumi

**GUI Applications:**

- Brave Browser
- Obsidian, GIMP, VLC, OBS Studio, Insomnia

See **[WINDOWS.md](WINDOWS.md)** for detailed Windows setup instructions.

## How to run

### Linux / macOS

```shell
export GITHUB_USERNAME=GyeongHoKim
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply $GITHUB_USERNAME
```

The setup will:

1. Install Ansible
2. Run the Ansible playbook to install system packages and mise
3. Install Oh My Zsh
4. Configure mise to auto-install language runtimes on first shell login

### Windows 11

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
$env:GITHUB_USERNAME = "GyeongHoKim"
& ([scriptblock]::Create((irm 'https://get.chezmoi.io/ps1'))) init --apply $env:GITHUB_USERNAME
```

The setup will:

1. Install development tools via winget (Windows Package Manager)
2. Set up PowerShell profile with mise activation
3. Deploy Neovim configuration (cross-platform)
4. Install mise for language version management

**Important:** After installation, restart your terminal and run `mise install` to install language runtimes.

## Managing Language Versions

After installation, use `mise` to manage language versions:

```bash
# Check installed versions
mise current

# Install different versions
mise use -g node@20
mise use python@3.11

# Per-project versions
cd my-project
mise use node@18  # Creates .tool-versions or mise.toml
```
