#!/bin/bash

# Verification script for dotfiles installation
# This script checks if essential tools are installed correctly

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

FAILED=0
PASSED=0

# Detect OS
OS="$(uname -s)"
if [[ "$OS" == "Linux" ]]; then
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        DISTRO="$ID"
    else
        DISTRO="unknown"
    fi
elif [[ "$OS" == "Darwin" ]]; then
    DISTRO="macos"
else
    DISTRO="unknown"
fi

# Check if running inside a container
is_container() {
    [[ -f /.dockerenv ]] || [[ -f /run/.containerenv ]] || grep -qE 'docker|lxc|containerd' /proc/1/cgroup 2>/dev/null
}

check_command() {
    local cmd=$1
    local description=$2

    if command -v "$cmd" &> /dev/null; then
        echo -e "${GREEN}[PASS]${NC} $description ($cmd)"
        ((PASSED++)) || true
    else
        echo -e "${RED}[FAIL]${NC} $description ($cmd)"
        ((FAILED++)) || true
    fi
}

check_command_alternatives() {
    local cmds=$1
    local description=$2

    for cmd in $cmds; do
        if command -v "$cmd" &> /dev/null; then
            echo -e "${GREEN}[PASS]${NC} $description ($cmd)"
            ((PASSED++)) || true
            return
        fi
    done
    echo -e "${RED}[FAIL]${NC} $description ($cmds)"
    ((FAILED++)) || true
}

check_command_with_paths() {
    local cmd=$1
    local description=$2
    shift 2
    local fallback_paths=("$@")

    if command -v "$cmd" &> /dev/null; then
        echo -e "${GREEN}[PASS]${NC} $description ($cmd)"
        ((PASSED++)) || true
        return
    fi

    for path in "${fallback_paths[@]}"; do
        if [[ -x "$path" ]]; then
            echo -e "${GREEN}[PASS]${NC} $description ($path)"
            ((PASSED++)) || true
            return
        fi
    done

    echo -e "${RED}[FAIL]${NC} $description ($cmd)"
    ((FAILED++)) || true
}

check_command_with_path() {
    local cmd=$1
    local fallback_path=$2
    local description=$3

    check_command_with_paths "$cmd" "$description" "$fallback_path"
}

check_file() {
    local file=$1
    local description=$2

    if [[ -f "$file" ]]; then
        echo -e "${GREEN}[PASS]${NC} $description ($file)"
        ((PASSED++)) || true
    else
        echo -e "${RED}[FAIL]${NC} $description ($file)"
        ((FAILED++)) || true
    fi
}

check_dir() {
    local dir=$1
    local description=$2

    if [[ -d "$dir" ]]; then
        echo -e "${GREEN}[PASS]${NC} $description ($dir)"
        ((PASSED++)) || true
    else
        echo -e "${RED}[FAIL]${NC} $description ($dir)"
        ((FAILED++)) || true
    fi
}

check_flatpak() {
    local app_id=$1
    local description=$2

    if ! command -v flatpak &> /dev/null; then
        echo -e "${RED}[FAIL]${NC} $description - flatpak not available"
        ((FAILED++)) || true
        return
    fi

    if flatpak list --app 2>/dev/null | grep -q "$app_id"; then
        echo -e "${GREEN}[PASS]${NC} $description ($app_id)"
        ((PASSED++)) || true
    else
        echo -e "${RED}[FAIL]${NC} $description ($app_id)"
        ((FAILED++)) || true
    fi
}

check_mise_tool() {
    local tool=$1
    local description=$2

    if ! command -v mise &> /dev/null; then
        echo -e "${RED}[FAIL]${NC} $description - mise not available"
        ((FAILED++)) || true
        return
    fi

    # Source mise if available
    if [[ -f "$HOME/.local/bin/mise" ]]; then
        eval "$("$HOME/.local/bin/mise" activate bash 2>/dev/null)" || true
    elif command -v mise &> /dev/null; then
        eval "$(mise activate bash 2>/dev/null)" || true
    fi

    # Check if tool is installed via mise
    if mise list 2>/dev/null | grep -q "$tool"; then
        echo -e "${GREEN}[PASS]${NC} $description (mise: $tool)"
        ((PASSED++)) || true
    elif command -v "$tool" &> /dev/null; then
        echo -e "${GREEN}[PASS]${NC} $description ($tool via PATH)"
        ((PASSED++)) || true
    else
        echo -e "${RED}[FAIL]${NC} $description ($tool)"
        ((FAILED++)) || true
    fi
}

# Check Homebrew cask app (macOS)
check_cask_app() {
    local app_name=$1
    local description=$2

    if [[ -d "/Applications/$app_name.app" ]] || [[ -d "$HOME/Applications/$app_name.app" ]]; then
        echo -e "${GREEN}[PASS]${NC} $description ($app_name)"
        ((PASSED++)) || true
    else
        echo -e "${RED}[FAIL]${NC} $description ($app_name)"
        ((FAILED++)) || true
    fi
}

echo "============================================"
echo "Dotfiles Installation Verification"
echo "============================================"
echo "OS: $OS | Distro: $DISTRO"
if is_container; then
    echo "Environment: Container (GUI apps not tested)"
fi
echo ""

# ===== CORE TOOLS (All platforms) =====
echo "--- Core Tools ---"
check_command_with_paths "chezmoi" "Chezmoi" "$HOME/bin/chezmoi" "$HOME/.local/bin/chezmoi" "/usr/local/bin/chezmoi"
check_command "mise" "mise version manager"
check_command "git" "Git"
check_command "gh" "GitHub CLI"
check_command "opencode" "OpenCode"
check_command "claude" "Claude Code"
check_command "gemini" "Gemini CLI"
check_command "qwen" "Qwen CLI"

echo ""
echo "--- Shell & Terminal ---"
check_command "zsh" "Zsh shell"
check_command "tmux" "Tmux"
check_file "$HOME/.zshrc" "Zsh config"
check_file "$HOME/.tmux.conf" "Tmux config"

echo ""
echo "--- Editors ---"
check_command "nvim" "Neovim"
check_dir "$HOME/.config/nvim" "Neovim config directory"

echo ""
echo "--- CLI Development Tools ---"
check_command "rg" "Ripgrep"
check_command "fzf" "FZF"
check_command_alternatives "fd fdfind" "fd-find"
check_command "lazygit" "Lazygit"
check_command_alternatives "task go-task" "Task (go-task)"
check_command_with_path "poetry" "$HOME/.local/bin/poetry" "Poetry"
check_command "luarocks" "LuaRocks"

echo ""
echo "--- Build Tools ---"
check_command "gcc" "GCC"
check_command "make" "Make"
check_command "autoconf" "Autoconf"

# ===== LANGUAGE RUNTIMES =====
echo ""
echo "--- Language Runtimes (via mise) ---"
check_mise_tool "node" "Node.js"
check_mise_tool "python" "Python"
check_mise_tool "go" "Go"
check_mise_tool "rust" "Rust"

# ===== INFRASTRUCTURE (All platforms) =====
echo ""
echo "--- Infrastructure Tools ---"
check_command "kubectl" "kubectl"
check_command "helm" "Helm"
check_command "terraform" "Terraform"

# ===== OS-SPECIFIC TOOLS =====
echo ""
echo "--- OS-Specific Tools ---"

if [[ "$OS" == "Linux" ]]; then
    # Linux-only CLI tools
    check_command "gnome-tweaks" "GNOME Tweaks"
    check_command_alternatives "inotifywait inotify-wait" "inotify-tools"
    check_command "flatpak" "Flatpak"
    check_command "docker" "Docker"

    # GUI apps and flatpak apps require display server, not testable in containers
    if ! is_container; then
        echo ""
        echo "--- GUI Applications (Native) ---"
        check_command "brave-browser" "Brave Browser"
        check_command "codium" "VSCodium"
        check_command "blender" "Blender"

        echo ""
        echo "--- Flatpak Applications ---"
        check_flatpak "com.obsproject.Studio" "OBS Studio"
        check_flatpak "org.videolan.VLC" "VLC Media Player"
        check_flatpak "org.tenacityaudio.Tenacity" "Tenacity Audio"
        check_flatpak "md.obsidian.Obsidian" "Obsidian"
        check_flatpak "org.gimp.GIMP" "GIMP"
        check_flatpak "rest.insomnia.Insomnia" "Insomnia"
        check_flatpak "com.github.johnfactotum.Foliate" "Foliate"
        check_flatpak "org.gnome.meld" "Meld"
        check_flatpak "org.sqlitebrowser.sqlitebrowser" "DB Browser for SQLite"
    fi

elif [[ "$OS" == "Darwin" ]]; then
    check_command "fswatch" "fswatch"

    # macOS Cask apps
    echo ""
    echo "--- GUI Applications (Homebrew Cask) ---"
    check_cask_app "Brave Browser" "Brave Browser"
    check_cask_app "VSCodium" "VSCodium"
    check_cask_app "Blender" "Blender"
    check_cask_app "OBS" "OBS Studio"
    check_cask_app "VLC" "VLC Media Player"
    check_cask_app "Obsidian" "Obsidian"
    check_cask_app "GIMP" "GIMP"
    check_cask_app "Insomnia" "Insomnia"
    check_cask_app "Meld" "Meld"
    check_cask_app "DB Browser for SQLite" "DB Browser for SQLite"
fi

# ===== FONTS =====
echo ""
echo "--- Fonts ---"
if [[ "$OS" == "Darwin" ]]; then
    FONT_DIR="$HOME/Library/Fonts"
else
    FONT_DIR="$HOME/.fonts"
fi

if ls "$FONT_DIR"/JetBrainsMono* &> /dev/null 2>&1; then
    echo -e "${GREEN}[PASS]${NC} JetBrains Mono Nerd Font"
    ((PASSED++)) || true
else
    echo -e "${RED}[FAIL]${NC} JetBrains Mono Nerd Font ($FONT_DIR)"
    ((FAILED++)) || true
fi

# ===== SUMMARY =====
echo ""
echo "============================================"
echo "Results Summary"
echo "============================================"
echo -e "  ${GREEN}Passed${NC}:  $PASSED"
echo -e "  ${RED}Failed${NC}:  $FAILED"
echo "============================================"

if [[ $FAILED -gt 0 ]]; then
    echo -e "${RED}Some checks failed!${NC}"
    exit 1
else
    echo -e "${GREEN}All checks passed!${NC}"
    exit 0
fi
