# dotfiles

This repo contains the configuration to setup my machines for web development. This is using [Chezmoi](https://chezmoi.io), the dotfile manager to setup the install.

Supported platforms: **Fedora**, **Debian/Ubuntu**, **macOS**, and **Windows 11**

```shell
export GITHUB_USERNAME=GyeongHoKim
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply $GITHUB_USERNAME
```

Windows11:

```powershell
$env:GITHUB_USERNAME = "GyeongHoKim"
iex "&{$(irm 'https://get.chezmoi.io/ps1')} -b '~/bin' --init --apply $env:GITHUB_USERNAME"
```

## What gets installed

### Development Environment

**Shell & Terminal:**

- zsh with [Oh My Zsh](https://ohmyz.sh/) (Linux/macOS)
- PowerShell with custom profile (Windows)
- tmux for terminal multiplexing (Linux/macOS)
- Windows Terminal (Windows)
- JetBrains Mono Nerd Font

**Editors:**

- Neovim (managed by [bob-nvim](https://github.com/MordechaiHadad/bob))
- Visual Studio Code
- Helix

**Language Runtimes** (via [mise](https://mise.jdx.dev)):

- Node.js (LTS - always latest Long-term Support version)
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

**Container & Infrastructure:**

- Docker Desktop (macOS/Windows) / Docker (Linux)
- Podman (Linux)
- Kubernetes: kubectl, helm
- Infrastructure as Code: terraform, pulumi
- Cloud CLIs: flyctl (Fly.io), doctl (DigitalOcean)

### GUI Applications

**Development:**

- Visual Studio Code
- Insomnia (API testing)
- Meld (diff/merge tool)
- DB Browser for SQLite

**Browsers:**

- Firefox / Firefox ESR
- Brave Browser

**Media & Graphics:**

- OBS Studio (streaming/recording)
- VLC Media Player
- Blender (3D graphics)
- Tenacity (audio editor)
- GIMP (image editor)

**Productivity:**

- Obsidian (note-taking)
- Foliate (ebook reader, Linux only)

**System:**

- GNOME Tweaks (Linux only)

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
4. Install bob-nvim (Neovim version manager)
5. Configure mise to auto-install language runtimes on first shell login

### Windows 11

See **[WINDOWS.md](WINDOWS.md)** for detailed Windows setup instructions.

```powershell
$env:GITHUB_USERNAME = "GyeongHoKim"
iex "&{$(irm 'https://get.chezmoi.io/ps1')}" -- init --apply $env:GITHUB_USERNAME
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
