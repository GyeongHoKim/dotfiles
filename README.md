# dotfiles

This repository contains my personal dotfiles managed with [dotbot](https://github.com/anishathalye/dotbot).

## 📁 Installation

### Quick Setup

Run the install script to set up all dotfiles and dependencies:

```bash
./install
```

This will:
- Install LazyVim prerequisites
- Set up Oh My Zsh and plugins
- Install Node Version Manager (nvm)
- Link all configuration files to their proper locations
- Source the zsh configuration

### Manual Setup Steps

If you prefer to run steps individually:

#### LazyVim
```bash
./setup-lazyvim.sh
```

#### Oh My Zsh
```bash
./setup-zsh.sh
```

#### Node Version Manager (nvm)
```bash
./setup-nvm.sh
```

### What Gets Linked

- `~/.zshrc` → zsh configuration with oh-my-zsh setup
- `~/.config/nvim/` → LazyVim-based Neovim configuration
- `~/.config/mcphub/` → MCP Hub configuration

## Known Issues

### ESLint LSP Server

> <https://github.com/LazyVim/LazyVim/issues/3383>

There is known issues with v4.10 ESLint LSP server that cannot read flat config files.  
If you use flat eslint config in your project, you should downgrade to v4.5 with MasonInstaller

```bash
:MsonInstall eslint-lsp 4.5.0
```
