#!/bin/bash

# Collect debug information for failed test analysis
# This script runs inside the container and saves debug info to /debug (volume mounted)

DEBUG_DIR="${DEBUG_DIR:-/debug}"

# Skip if debug directory is not mounted
if [[ ! -d "$DEBUG_DIR" ]] || [[ ! -w "$DEBUG_DIR" ]]; then
    echo "[DEBUG] Debug directory not available, skipping debug collection"
    exit 0
fi

echo "[DEBUG] Collecting debug information to $DEBUG_DIR"

# System info
{
    echo "=== System Info ==="
    uname -a
    echo ""
    cat /etc/os-release 2>/dev/null || true
} > "$DEBUG_DIR/system_info.txt"

# Environment variables
{
    echo "=== Environment Variables ==="
    env | sort
} > "$DEBUG_DIR/env.txt"

# Home directory structure
{
    echo "=== Home Directory Structure ==="
    ls -la "$HOME"
    echo ""
    echo "=== .config directory ==="
    ls -la "$HOME/.config" 2>/dev/null || echo "(not found)"
    echo ""
    echo "=== .local directory ==="
    ls -laR "$HOME/.local" 2>/dev/null | head -100 || echo "(not found)"
} > "$DEBUG_DIR/home_structure.txt"

# Installed dotfiles
{
    echo "=== Chezmoi managed files ==="
    if command -v chezmoi &>/dev/null; then
        chezmoi managed 2>/dev/null || echo "(failed to list)"
    else
        echo "(chezmoi not found)"
    fi
} > "$DEBUG_DIR/chezmoi_managed.txt"

# Shell configs
for file in .bashrc .zshrc .profile .bash_profile; do
    if [[ -f "$HOME/$file" ]]; then
        cp "$HOME/$file" "$DEBUG_DIR/$file" 2>/dev/null || true
    fi
done

# Config files
mkdir -p "$DEBUG_DIR/config"
for dir in nvim tmux; do
    if [[ -d "$HOME/.config/$dir" ]]; then
        cp -r "$HOME/.config/$dir" "$DEBUG_DIR/config/" 2>/dev/null || true
    fi
done

# Installed commands check
{
    echo "=== Command availability ==="
    for cmd in chezmoi git zsh tmux nvim mise fzf rg fd lazygit; do
        if command -v "$cmd" &>/dev/null; then
            echo "[OK] $cmd: $(command -v "$cmd")"
        else
            echo "[MISSING] $cmd"
        fi
    done
} > "$DEBUG_DIR/commands.txt"

# PATH
{
    echo "=== PATH ==="
    echo "$PATH" | tr ':' '\n'
} > "$DEBUG_DIR/path.txt"

# Mise status (if available)
if command -v mise &>/dev/null; then
    {
        echo "=== Mise Status ==="
        mise doctor 2>&1 || true
        echo ""
        echo "=== Mise List ==="
        mise list 2>&1 || true
    } > "$DEBUG_DIR/mise_status.txt"
fi

echo "[DEBUG] Debug collection complete"
ls -la "$DEBUG_DIR/"
