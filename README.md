# dotfiles

This repository contains my personal dotfiles. Each tool has different installation methods:

## 📁 Installation

### LazyVim

Step 1: Install Prerequisites

```bash
./setup-lazyvim.sh
```

Step 2: configure Neovim

```bash
# Install specific configurations
stow nvim    # Neovim configuration
```

### Oh My Zsh (requires special setup)

**Step 1**: Install Oh My Zsh and plugins

```bash
./setup-zsh.sh
```

**Step 2**: Link the configuration using stow

```bash
stow zsh
```

**Step 3**: Restart your terminal or source the config

```bash
source ~/.zshrc
```

### Node Version Manager (nvm)

needed env variables are already in .zshrc file.

```bash
./setup-nvm.sh
```

## Known Issues

### ESLint LSP Server

> <https://github.com/LazyVim/LazyVim/issues/3383>

There is known issues with v4.10 ESLint LSP server that cannot read flat config files.  
If you use flat eslint config in your project, you should downgrade to v4.5 with MasonInstaller

```bash
:MsonInstall eslint-lsp 4.5.0
```
