# dotfiles

[![Linux & macOS](https://github.com/GyeongHoKim/dotfiles/actions/workflows/test-install.yml/badge.svg)](https://github.com/GyeongHoKim/dotfiles/actions/workflows/test-install.yml)

This repo contains the configuration to setup my machines for web development. It uses [Chezmoi](https://chezmoi.io) as the dotfile manager.

Supported platforms: **Fedora**, **Debian/Ubuntu**, **macOS**, and **Windows 11**

## Continuous integration

[`.github/workflows/test-install.yml`](.github/workflows/test-install.yml) exercises **only the server profile** (`dotfiles_profile=server`), matching headless GitHub-hosted runners: **Fedora**, **Ubuntu**, and **Debian** via Docker, plus **macOS** on `macos-latest`. Each job runs `tests/verify_install.sh` with `DOTFILES_PROFILE=server`. Desktop/GUI installs are not tested in CI. Windows is not covered by this workflow.

## Quick install

**Linux / macOS** — default (includes GUI desktop apps where applicable):

```shell
export GITHUB_USERNAME=GyeongHoKim
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply $GITHUB_USERNAME
```

**Headless / server (no GUI packages):** if you want to install **without** GUI-oriented applications—especially on **server machines**—use `dotfiles_profile=server`. Pass it on the first apply:

```shell
export GITHUB_USERNAME=GyeongHoKim
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply $GITHUB_USERNAME --override-data '{"dotfiles_profile":"server"}'
```

Or after setup, run:

```shell
chezmoi apply --override-data '{"dotfiles_profile":"server"}'
```

To keep this choice permanently, add to `~/.config/chezmoi/chezmoi.toml`:

```toml
[data]
    dotfiles_profile = "server"
```

The default profile is `desktop` (see `.chezmoi.toml.tmpl`). With `server`, the playbooks and Windows script skip things like Flatpak/GUI apps, WezTerm, Brave/VSCodium/Blender, macOS Casks and Docker Desktop DMG, and the listed Windows GUI winget packages, plus Claude Code installation on Unix.

---

**Windows 11:**

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
$env:GITHUB_USERNAME = "GyeongHoKim"
& ([scriptblock]::Create((irm 'https://get.chezmoi.io/ps1'))) init --apply $env:GITHUB_USERNAME
```

**Windows, headless / server (no GUI packages):**

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
$env:GITHUB_USERNAME = "GyeongHoKim"
& ([scriptblock]::Create((irm 'https://get.chezmoi.io/ps1'))) init --apply $env:GITHUB_USERNAME --override-data '{"dotfiles_profile":"server"}'
```

> **Windows prerequisite:** Enable **Developer Mode** (`Settings > Privacy & Security > For Developers`) so symlinks work without admin (agent skills use symlinks).

---

## What gets installed

Versions for language runtimes are **“latest” / LTS** at install time (see `dot_config/mise/config.toml`).

**Shell and terminal:** zsh, [Oh My Zsh](https://ohmyz.sh/), tmux, JetBrains Mono Nerd Font (download).

**Editor:** Neovim (LazyVim-oriented layout from this repo).

**Language runtimes ([mise](https://mise.jdx.dev)):** Node.js LTS, Python, Go, Rust (via `mise install` and related hooks).

**CLI:** Git, GitHub CLI (`gh`), ripgrep, fzf, fd, lazygit, go-task, zoxide, build tooling (gcc, make, autoconf, etc.), Poetry (after Python), LuaRocks, Bun (install script).

**Infra:** kubectl, helm, terraform.

**AI / npm (as configured):** Ansible installs **Claude Code** on Linux/macOS when not using the `server` profile. Global npm defaults include `opencode-ai` (`dot_default-npm-packages`) when Node is installed via mise.

**Linux (Fedora, Debian/Ubuntu):** Docker CE (+ compose/buildx plugins), GNOME Tweaks, inotify-tools, flatpak, podman-compose, Brave Browser, VSCodium (`codium`), Blender, WezTerm (Fedora COPR / Debian repo), Flatpak apps from Flathub (OBS, VLC, Tenacity, Obsidian, GIMP, Insomnia, Foliate, Meld, DB Browser for SQLite), Tailscale install script.

**macOS:** Homebrew formulae (git, mise, kubectl, terraform, fswatch, etc.), Homebrew Casks (VSCodium, Brave, Blender, OBS, VLC, Obsidian, GIMP, Insomnia, Meld, DB Browser for SQLite, WezTerm), Docker Desktop (DMG when not in CI), Rosetta 2 on Apple Silicon when applicable.

**Windows:** winget installs Git, gh, Vim, Neovim, Visual Studio Code, Windows Terminal, WezTerm, PowerShell 7+, fzf, GlazeWM, Zebar, Docker Desktop, kubectl, Terraform, Pulumi, Helm, Task, Node LTS, GNU Make, ripgrep, fd, tmux, zoxide, lazygit, Gpg4win, Brave, Obsidian, GIMP, VLC, OBS, Insomnia, mise, Bun (script), Poetry when `py` is available, and Claude Code (desktop profile only; not installed with `server`, and Windows is not in CI).

---

## How the setup runs

**Linux / macOS** — roughly: install Ansible, run `ansible-playbook` on `dot_bootstrap/setup.yml` with `dotfiles_profile` from Chezmoi data, Oh My Zsh and other `run_once_*` hooks, then mise-related tooling.

**Windows** — packages are driven by the rendered PowerShell script and the same `dotfiles_profile` value.

---

## Managing language versions

```bash
mise current
mise use -g node@20
mise use python@3.11
cd my-project && mise use node@18
```
