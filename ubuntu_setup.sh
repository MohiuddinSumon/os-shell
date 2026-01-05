#!/bin/bash

# Cleanup script if ubuntu_setup.sh was accidentally run with sudo
# This removes root-owned configurations and allows you to run the script correctly

echo "=============================================="
echo "  Cleanup Script - Undo Sudo Installation"
echo "=============================================="
echo ""
echo "This script will:"
echo "1. Remove root user configurations from /root"
echo "2. Remove any root-owned files in your home directory"
echo "3. NOT uninstall system packages (those are fine)"
echo ""
read -p "Continue? (y/n): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

echo ""
echo "Cleaning up..."
echo ""

# Remove root's Oh My Zsh and configs
if [ -d "/root/.oh-my-zsh" ]; then
    echo "Removing /root/.oh-my-zsh..."
    sudo rm -rf /root/.oh-my-zsh
fi

if [ -f "/root/.zshrc" ]; then
    echo "Removing /root/.zshrc..."
    sudo rm -f /root/.zshrc
fi

if [ -f "/root/.config/starship.toml" ]; then
    echo "Removing /root/.config/starship.toml..."
    sudo rm -f /root/.config/starship.toml
fi

# Remove root's NVM
if [ -d "/root/.nvm" ]; then
    echo "Removing /root/.nvm..."
    sudo rm -rf /root/.nvm
fi

# Remove root's UV
if [ -d "/root/.local/share/uv" ]; then
    echo "Removing /root/.local/share/uv..."
    sudo rm -rf /root/.local/share/uv
fi

if [ -d "/root/.cargo" ]; then
    echo "Removing /root/.cargo (from UV/Starship)..."
    sudo rm -rf /root/.cargo
fi

# Check for root-owned files in current user's home
echo ""
echo "Checking for root-owned files in $HOME..."
ROOT_OWNED_FILES=$(find "$HOME" -maxdepth 3 -user root 2>/dev/null || true)

if [ -n "$ROOT_OWNED_FILES" ]; then
    echo "Found root-owned files in your home directory:"
    echo "$ROOT_OWNED_FILES"
    echo ""
    read -p "Remove these root-owned files? (y/n): " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "$ROOT_OWNED_FILES" | while read -r file; do
            if [ -n "$file" ]; then
                echo "Removing: $file"
                sudo rm -rf "$file"
            fi
        done
    fi
else
    echo "No root-owned files found in $HOME"
fi

echo ""
echo "=============================================="
echo "  Cleanup Complete!"
echo "=============================================="
echo ""
echo "What was NOT removed (these are safe):"
echo "  - System packages (apt packages)"
echo "  - FiraCode font"
echo "  - Docker, PostgreSQL, VS Code, etc."
echo ""
echo "What WAS removed:"
echo "  - Root user configs (/root/.zshrc, etc.)"
echo "  - Root-owned files in your home directory"
echo ""
echo "Next steps:"
echo "  1. Run the setup script correctly: ./ubuntu_setup.sh"
echo "  2. It will detect installed packages and skip them"
echo "  3. It will create configs in YOUR home directory"
echo ""
