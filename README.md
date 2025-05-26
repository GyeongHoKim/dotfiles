# dotfiles

Cross-platform dotfiles managed with [dotbot](https://github.com/anishathalye/dotbot) for Unix and custom installer for Windows.

## 🖥️ Supported Platforms

- ✅ **macOS** - Full support with Homebrew, Zsh, and Oh My Zsh
- ✅ **Linux** - Full support with native package managers and Zsh
- ✅ **Windows** - Full support with PowerShell, Windows Terminal, and native tools

## 📁 Installation

### 🚀 Universal Installer (Recommended)

We provide a cross-platform installer that automatically detects your OS and installs appropriate tools:

```bash
# Clone the repository
git clone https://github.com/gyeonghokim/dotfiles.git
cd dotfiles

# Run the installer
# On Windows (PowerShell):
./install.ps1
# Or use the batch file:
./install.bat

# On macOS/Linux:
./install
```

The installer will:
- Detect your operating system
- Install required package managers if needed
- Install Neovim and development tools
- Set up your shell configuration (Zsh for Unix, PowerShell for Windows)
- Link all configuration files

### 🪟 Windows-Specific Setup

For Windows users, the installer will:

1. **Install a package manager** (Scoop recommended)
2. **Install core tools**:
   - Neovim
   - Git
   - Ripgrep, fd, fzf
   - LazyGit
   - Nerd Fonts
3. **Configure PowerShell** with:
   - Oh-My-Posh (Windows equivalent of Oh-My-Zsh)
   - PSReadLine (autosuggestions and syntax highlighting)
   - Git aliases and functions
   - Custom prompt themes
4. **Set up Neovim** with LazyVim configuration

#### Prerequisites for Windows

- Windows 10/11
- PowerShell 5.1 or PowerShell Core 7+
- Windows Terminal (recommended): `winget install Microsoft.WindowsTerminal`
- Administrator privileges for symlink creation

#### Post-Installation for Windows

1. **Install Windows Terminal** for the best experience
2. **Set a Nerd Font** in Windows Terminal settings:
   - Settings → Profiles → Defaults → Font face → "Hack Nerd Font"
3. **Enable PowerShell profile**:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

### 🍎 macOS/Linux Manual Setup

If you prefer the traditional installation:

```bash
# Install all dependencies and configurations
./install

# Or run individual setup scripts:
./setup-lazyvim.sh  # Install Neovim and tools
./setup-zsh.sh      # Install Oh My Zsh and plugins
./setup-nvm.sh      # Install Node Version Manager
```

## 📂 What Gets Installed

### Unix Systems (macOS/Linux)
- `~/.zshrc` → Zsh configuration with Oh My Zsh
- `~/.config/nvim/` → LazyVim-based Neovim configuration
- `~/.config/mcphub/` → MCP Hub configuration

### Windows Systems
- `~/AppData/Local/nvim/` → LazyVim-based Neovim configuration
- `~/Documents/PowerShell/Microsoft.PowerShell_profile.ps1` → PowerShell profile
- `~/AppData/Local/mcphub/` → MCP Hub configuration

## 🛠️ Included Tools

| Tool | macOS | Linux | Windows | Purpose |
|------|-------|-------|---------|---------|
| Neovim | ✅ brew | ✅ apt/yum/pacman | ✅ scoop/choco/winget | Editor |
| Git | ✅ brew | ✅ native | ✅ native | Version control |
| Ripgrep | ✅ brew | ✅ native | ✅ scoop/choco/winget | Fast search |
| fd | ✅ brew | ✅ native | ✅ scoop/choco/winget | Fast find |
| fzf | ✅ brew | ✅ native | ✅ scoop/choco/winget | Fuzzy finder |
| LazyGit | ✅ brew | ✅ native | ✅ scoop/choco/winget | Git UI |
| Oh My Zsh | ✅ | ✅ | ❌ | Zsh framework |
| Oh My Posh | ❌ | ❌ | ✅ | PowerShell theming |

## 🎨 Shell Enhancements

### Unix (Zsh + Oh My Zsh)
- Agnoster theme with git integration
- Autosuggestions from history
- Syntax highlighting
- Git aliases and shortcuts
- NVM integration

### Windows (PowerShell + Oh My Posh)
- Agnoster theme (matching Unix setup)
- PSReadLine for autosuggestions
- Syntax highlighting
- Git aliases and shortcuts
- PowerShell gallery modules

## 🔧 Configuration

### Environment Variables
Create a file to store machine-specific environment variables:
- Unix: `~/.env_vars`
- Windows: `~/.env_vars.ps1`

### Customizing Themes

**Unix (Oh My Zsh)**:
Edit `~/.zshrc` and change:
```bash
ZSH_THEME="agnoster"  # Change to any Oh My Zsh theme
```

**Windows (Oh My Posh)**:
Edit your PowerShell profile and change:
```powershell
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/agnoster.omp.json"
```

## 🐛 Troubleshooting

### Windows Issues

**Symlinks not working**:
- Run PowerShell as Administrator
- Enable developer mode in Windows Settings

**Execution Policy Error**:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Fonts not displaying correctly**:
- Install a Nerd Font from [nerdfonts.com](https://www.nerdfonts.com/)
- Set it in Windows Terminal settings

### Cross-Platform Issues

**Go not found**:
- Install Go from [golang.org](https://golang.org/dl/)
- Or use your package manager

**Neovim plugins not loading**:
- Run `:Lazy sync` in Neovim
- Check `:checkhealth` for issues

## 📚 Known Issues

### ESLint LSP Server

> <https://github.com/LazyVim/LazyVim/issues/3383>

There are known issues with v4.10 ESLint LSP server that cannot read flat config files.  
If you use flat eslint config in your project, you should downgrade to v4.5 with Mason:

```vim
:MasonInstall eslint-lsp@4.5.0
```

## 🤝 Contributing

Feel free to submit issues and pull requests. Contributions for better cross-platform support are especially welcome!

## 📝 License

MIT License - see LICENSE file for details
