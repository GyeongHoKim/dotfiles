# dotfiles

[![Linux & macOS](https://github.com/GyeongHoKim/dotfiles/actions/workflows/test-install.yml/badge.svg)](https://github.com/GyeongHoKim/dotfiles/actions/workflows/test-install.yml)

This repo contains the configuration to setup my machines for web development. It uses [Chezmoi](https://chezmoi.io) as the dotfile manager.

Supported platforms: **Fedora**, **Debian/Ubuntu**, **macOS**, and **Windows 11**

## Continuous integration

[`.github/workflows/test-install.yml`](.github/workflows/test-install.yml) exercises **only the server profile** (`dotfiles_profile=server`), matching headless GitHub-hosted runners: **Fedora**, **Ubuntu**, and **Debian** via Docker, plus **macOS** on `macos-latest` and **Windows Server** on `windows-latest`. Each job runs `tests/verify_install.sh` (or `tests/verify_install.ps1` on Windows) with `DOTFILES_PROFILE=server`. Desktop/GUI installs are not tested in CI; GitHub-hosted x64 Windows runners are Windows Server, so the Windows 11 desktop packages are not covered.

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

The default profile is `desktop` (see `.chezmoi.toml.tmpl`). With `server`, the playbooks and Windows script skip things like Flatpak/GUI apps, WezTerm, Brave/VSCodium/Blender, macOS Casks and Docker Desktop DMG, and the listed Windows GUI winget packages.

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

## Recovering from a failed install

Bootstrap runs Ansible and several `run_once_*` scripts. If it fails partway through, **re-running the same install command is often not enough**: chezmoi may still use an old source checkout, or scripts may be treated as already finished. After a fix is released, start from a clean chezmoi state and re-run bootstrap from the beginning.

### Linux / macOS

**Option A — full clean restart (recommended after a fix release)**

Removes chezmoi's source, config, and script state. Files already applied to your home directory are kept; bootstrap scripts run again on the next apply.

```shell
export GITHUB_USERNAME=GyeongHoKim
# Add --override-data when using the server profile (see Quick install above).

chezmoi purge --force

sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply $GITHUB_USERNAME
# Server profile example:
# sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply $GITHUB_USERNAME --override-data '{"dotfiles_profile":"server"}'
```

**Option B — keep chezmoi, refresh source and re-run scripts**

Use this if you prefer not to remove chezmoi's configuration entirely. Requires `chezmoi` on your `PATH` (often `~/bin` or `~/.local/bin` after the first install attempt).

```shell
export GITHUB_USERNAME=GyeongHoKim

# Fetch the latest dotfiles from GitHub and re-apply
chezmoi update --init --apply
# Server profile example:
# chezmoi update --init --apply --override-data '{"dotfiles_profile":"server"}'

# Force run_once_* scripts (e.g. Ansible bootstrap) to run again
chezmoi state delete-bucket --bucket=scriptState
chezmoi apply
# Server profile example:
# chezmoi apply --override-data '{"dotfiles_profile":"server"}'
```

If `run_onchange_*` hooks should also re-run (for example after `dot_bootstrap/setup.yml` changed), clear their state as well:

```shell
chezmoi state delete-bucket --bucket=entryState
chezmoi apply
```

**Linux only — package manager errors after a partial run**

Ansible may leave half-configured APT or DNF repositories before it exits. If `apt update` or the playbook still fails with conflicting repo settings (for example duplicate `Signed-By` keyrings), fix or remove the broken entries under `/etc/apt/sources.list.d/` (or the equivalent DNF repo files), then run **Option A** or **Option B** again.

### Windows 11

```powershell
$env:GITHUB_USERNAME = "GyeongHoKim"

chezmoi purge --force

& ([scriptblock]::Create((irm 'https://get.chezmoi.io/ps1'))) init --apply $env:GITHUB_USERNAME
# Server profile example:
# & ([scriptblock]::Create((irm 'https://get.chezmoi.io/ps1'))) init --apply $env:GITHUB_USERNAME --override-data '{"dotfiles_profile":"server"}'
```

If you prefer not to purge, run `chezmoi update --init --apply`, then `chezmoi state delete-bucket --bucket=scriptState`, then `chezmoi apply` (with `--override-data` if you use the server profile).

---

## What gets installed

Versions for language runtimes are **“latest” / LTS** at install time (see `dot_config/mise/config.toml`).

**Shell and terminal:** zsh, [Oh My Zsh](https://ohmyz.sh/), tmux, JetBrains Mono Nerd Font (download).

**Editor:** Neovim (LazyVim-oriented layout from this repo).

**Language runtimes ([mise](https://mise.jdx.dev)):** Node.js LTS, Python, Go, Rust (via `mise install` and related hooks).

**CLI:** Git, GitHub CLI (`gh`), ripgrep, fzf, fd, lazygit, [glow](https://github.com/charmbracelet/glow) (terminal markdown reader), go-task, zoxide, build tooling (gcc, make, autoconf, etc.), Poetry (after Python), LuaRocks, Bun (install script).

**Infra:** kubectl, helm, terraform.

**Linux (Fedora, Debian/Ubuntu):** Docker CE (+ compose/buildx plugins), GNOME Tweaks, inotify-tools, flatpak, podman-compose, Brave Browser, VSCodium (`codium`), Blender, WezTerm (Fedora COPR / Debian repo), Flatpak apps from Flathub (OBS, VLC, Tenacity, Obsidian, GIMP, Insomnia, Foliate, Meld, DB Browser for SQLite), Tailscale install script.

**macOS:** Homebrew formulae (git, mise, kubectl, terraform, fswatch, etc.), Homebrew Casks (VSCodium, Brave, Blender, OBS, VLC, Obsidian, GIMP, Insomnia, Meld, DB Browser for SQLite, WezTerm), Docker Desktop (DMG when not in CI), Rosetta 2 on Apple Silicon when applicable.

**Windows:** winget installs Git, gh, Vim, Neovim, Visual Studio Code, Windows Terminal, WezTerm, PowerShell 7+, fzf, GlazeWM, Zebar, Docker Desktop, kubectl, Terraform, Pulumi, Helm, Task, Node LTS, GNU Make, ripgrep, glow, fd, tmux, zoxide, lazygit, Gpg4win, Brave, Obsidian, GIMP, VLC, OBS, Insomnia, mise, Bun (script), and Poetry when `py` is available. With the server profile, the GUI apps (VS Code, Windows Terminal, WezTerm, GlazeWM, Zebar, Docker Desktop, Brave, Obsidian, GIMP, VLC, OBS, Insomnia) are skipped.

---

## Agent skills

This repo ships global agent skills under `dot_agents/skills/`, which Chezmoi deploys to `~/.agents/skills/`. That directory is the **canonical** global store used by the [skills](https://skills.sh/) CLI, but copying files there does **not** automatically make them available in every AI coding agent.

| Agent type | Reads from | Action needed |
|------------|------------|---------------|
| Universal (e.g. Cline, Gemini CLI) | `~/.agents/skills/` | None — skills are picked up directly |
| Non-universal (e.g. Claude Code, Cursor, Codex) | Agent-specific dir (e.g. `~/.claude/skills/`, `~/.cursor/skills/`) | Symlink from the canonical copy (see below) |

### Link skills to your AI CLI

1. Install the AI CLI tools you want (Claude Code, Cursor, Codex, OpenCode, etc.).
2. Run the [skills CLI](https://skills.sh/docs/cli) to symlink the global skills from `~/.agents/skills/` into each agent's directory. Symlinks are the default install method.

**All installed agents** (auto-detected):

```bash
npx skills add ~/.agents/skills -g -a '*' -y --all
```

**Specific agents** (repeat `-a` for each):

```bash
npx skills add ~/.agents/skills -g -a claude-code -a cursor -a codex -y --all
```

Common agent identifiers: `claude-code`, `cursor`, `codex`, `windsurf`, `github-copilot`, `opencode`. See `npx skills add --help` for the full list.

Verify linked skills for an agent:

```bash
npx skills ls -g -a claude-code
```

Re-run the `skills add` command after adding new skills to this repo or when you install another AI CLI. On Windows, symlinks require **Developer Mode** (see the Windows prerequisite in [Quick install](#quick-install)).

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
