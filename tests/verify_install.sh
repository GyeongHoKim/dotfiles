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

check_command() {
    local cmd=$1
    local description=$2

    if command -v "$cmd" &> /dev/null; then
        echo -e "${GREEN}[PASS]${NC} $description ($cmd)"
        ((PASSED++))
    else
        echo -e "${RED}[FAIL]${NC} $description ($cmd)"
        ((FAILED++))
    fi
}

check_file() {
    local file=$1
    local description=$2

    if [[ -f "$file" ]]; then
        echo -e "${GREEN}[PASS]${NC} $description ($file)"
        ((PASSED++))
    else
        echo -e "${RED}[FAIL]${NC} $description ($file)"
        ((FAILED++))
    fi
}

check_dir() {
    local dir=$1
    local description=$2

    if [[ -d "$dir" ]]; then
        echo -e "${GREEN}[PASS]${NC} $description ($dir)"
        ((PASSED++))
    else
        echo -e "${RED}[FAIL]${NC} $description ($dir)"
        ((FAILED++))
    fi
}

echo "============================================"
echo "Dotfiles Installation Verification"
echo "============================================"
echo ""

echo "--- Package Manager Tools ---"
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

echo ""
echo "--- CLI Development Tools ---"
check_command "rg" "Ripgrep"
check_command "fzf" "FZF"
check_command "fd" "fd-find"

echo ""
echo "--- Build Tools ---"
check_command "gcc" "GCC"
check_command "make" "Make"

echo ""
echo "--- Container & Infrastructure ---"
check_command "docker" "Docker"
check_command "kubectl" "kubectl"
check_command "helm" "Helm"
check_command "terraform" "Terraform"

echo ""
echo "--- Additional Tools ---"
check_command "code" "VS Code"
check_command "lazygit" "Lazygit"

echo ""
echo "============================================"
echo "Results: ${GREEN}$PASSED passed${NC}, ${RED}$FAILED failed${NC}"
echo "============================================"

if [[ $FAILED -gt 0 ]]; then
    echo -e "${RED}Some checks failed!${NC}"
    exit 1
else
    echo -e "${GREEN}All checks passed!${NC}"
    exit 0
fi
