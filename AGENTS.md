# AGENTS.md

This file provides guidance to AI Agents when working with code in this repository.

## Repository Overview

Multi-platform dotfiles repository using **Chezmoi** as the dotfile manager. Sets up a complete web development environment across Linux (Fedora, Debian, Ubuntu), macOS, and Windows 11.

## Key Commands

### Testing

```bash
# Run tests for a specific platform
./tests/run_tests.sh fedora
./tests/run_tests.sh ubuntu
./tests/run_tests.sh debian
./tests/run_tests.sh darwin

# Run all platform tests
./tests/run_tests.sh all

# Run tests in parallel
./tests/run_tests.sh parallel
```

### Chezmoi Commands

```bash
chezmoi diff                    # Preview changes before applying
chezmoi apply                   # Apply configuration to system
chezmoi edit <file>             # Edit a managed file
chezmoi add <file>              # Add new file to dotfiles
chezmoi state delete-bucket --bucket=scriptState  # Re-run all scripts
```

## Architecture

### Chezmoi File Naming Conventions

- `dot_` prefix → becomes a dotfile (e.g., `dot_zshrc` → `~/.zshrc`)
- `run_once_` prefix → executes once during initial setup
- `run_onchange_` prefix → re-executes when file contents change
- `.tmpl` suffix → Go template file with platform-specific logic
- `private_` prefix → sets restricted file permissions

### Platform Detection

Templates use Chezmoi variables for cross-platform logic:

- `{{ .chezmoi.os }}` - Operating system (linux, darwin, windows)
- `{{ .chezmoi.osRelease.id }}` - Distribution ID (fedora, ubuntu, debian)

Platform-specific files are excluded via `.chezmoiignore`.

### Installation Flow

**Linux/macOS:**

1. `run_once_install_ansible.sh.tmpl` - Installs Ansible
2. `dot_bootstrap/setup.yml` - Ansible playbook installs packages
3. `run_once_install_ohmyzsh.sh.tmpl` - Installs Oh My Zsh
4. `run_once_after_install_mise_tools.sh.tmpl` - Installs language runtimes via mise
5. `run_once_rustup.sh.tmpl` - Installs Rust toolchain

**Windows:**

1. `run_once_install_packages_windows.ps1.tmpl` - Installs packages via winget
2. `run_once_install_ohmyposh.ps1.tmpl` - Installs PowerShell prompt theme
3. `run_onchange_after_setup_nvim_windows.ps1.tmpl` - Configures Neovim path

### Key Directories

- `dot_config/nvim/` - Neovim configuration (LazyVim framework, Lua-based)
- `dot_config/mise/config.toml` - Language runtime versions (Node, Python, Go, Rust)
- `dot_bootstrap/setup.yml` - Ansible playbook for Linux/macOS package installation
- `tests/` - Verification scripts and Docker-based test infrastructure
- `Documents/PowerShell/` - Windows PowerShell profile

### OS-Specific Package Differences

**All platforms:** chezmoi, mise, git, gh, zsh, tmux, nvim, ripgrep, fzf, fd, lazygit, go-task, poetry, luarocks, gcc, make, autoconf, kubectl, helm, terraform, pulumi, JetBrains Mono font

**Linux only:** gnome-tweaks, inotify-tools, flatpak, podman-compose, Docker (docker-ce), native packages (VS Code, Brave, Blender), Flatpak apps (OBS, VLC, Tenacity, Obsidian, GIMP, Insomnia, Foliate, Meld, DB Browser)

**macOS only:** fswatch, Docker Desktop, Homebrew Cask apps (VS Code, Brave, Blender, OBS, VLC, Obsidian, GIMP, Insomnia, Meld, DB Browser)

### CI/CD

GitHub Actions workflow (`.github/workflows/test-install.yml`) runs on:

- Push/PR to main branch
- Weekly schedule (Sunday 00:00 UTC)
- Manual trigger

Tests run in Docker containers for Linux distributions (CLI tools only) and native runner for macOS (full test including GUI apps).
