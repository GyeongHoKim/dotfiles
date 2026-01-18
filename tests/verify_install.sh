#!/bin/bash

# Verification script for dotfiles installation
# This script checks if essential tools are installed correctly

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

FAILED=0
PASSED=0
SKIPPED=0

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

check_command_optional() {
    local cmd=$1
    local description=$2

    if command -v "$cmd" &> /dev/null; then
        echo -e "${GREEN}[PASS]${NC} $description ($cmd)"
        ((PASSED++)) || true
    else
        echo -e "${YELLOW}[SKIP]${NC} $description ($cmd) - optional"
        ((SKIPPED++)) || true
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
        echo -e "${YELLOW}[SKIP]${NC} $description - flatpak not available"
        ((SKIPPED++)) || true
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
        echo -e "${YELLOW}[SKIP]${NC} $description - mise not available"
        ((SKIPPED++)) || true
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

echo "============================================"
echo "Dotfiles Installation Verification"
echo "============================================"
echo ""

# ===== CORE TOOLS =====
echo "--- Package Manager Tools ---"
check_command_with_paths "chezmoi" "Chezmoi" "$HOME/bin/chezmoi" "$HOME/.local/bin/chezmoi" "/usr/local/bin/chezmoi"
check_command "mise" "mise version manager"
check_command "git" "Git"
check_command "gh" "GitHub CLI"

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
check_command_optional "code" "VS Code"

echo ""
echo "--- CLI Development Tools ---"
check_command "rg" "Ripgrep"
check_command "fzf" "FZF"
check_command_alternatives "fd fdfind" "fd-find"
check_command "lazygit" "Lazygit"
check_command_alternatives "task go-task" "Task (go-task)"
check_command_with_path "poetry" "$HOME/.local/bin/poetry" "Poetry (Python package manager)"
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

# ===== INFRASTRUCTURE =====
echo ""
echo "--- Container & Infrastructure ---"
check_command_optional "docker" "Docker"
check_command "kubectl" "kubectl"
check_command "helm" "Helm"
check_command "terraform" "Terraform"
check_command_optional "pulumi" "Pulumi"
check_command_optional "flyctl" "Fly.io CLI"
check_command_optional "doctl" "DigitalOcean CLI"

# ===== BROWSERS & SYSTEM =====
echo ""
echo "--- Browsers & System ---"
check_command_optional "firefox" "Firefox"
check_command_optional "brave-browser" "Brave Browser"
check_command_optional "gnome-tweaks" "GNOME Tweaks"
check_command_optional "blender" "Blender"

# ===== FLATPAK APPS (Linux only, skip in containers) =====
if [[ "$(uname -s)" == "Linux" ]] && command -v flatpak &> /dev/null; then
    if is_container; then
        echo ""
        echo "--- Flatpak Applications (skipped in container) ---"
        echo -e "${YELLOW}[SKIP]${NC} Flatpak apps - not supported in container environment"
        ((SKIPPED++)) || true
    else
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
fi

# ===== FONTS =====
echo ""
echo "--- Fonts ---"
if [[ "$(uname -s)" == "Darwin" ]]; then
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
echo -e "  ${YELLOW}Skipped${NC}: $SKIPPED"
echo "============================================"

if [[ $FAILED -gt 0 ]]; then
    echo -e "${RED}Some checks failed!${NC}"
    exit 1
else
    echo -e "${GREEN}All required checks passed!${NC}"
    exit 0
fi
