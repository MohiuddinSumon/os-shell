#!/bin/bash

# Ubuntu Fresh Install Auto-Configuration Script
# This script installs and configures development tools automatically
# It skips installations if tools are already present

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Log file
LOGFILE="$HOME/ubuntu-setup-$(date +%Y%m%d-%H%M%S).log"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOGFILE"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOGFILE"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOGFILE"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOGFILE"
}

print_skip() {
    echo -e "${YELLOW}[SKIP]${NC} $1 already installed" | tee -a "$LOGFILE"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Start
clear
echo "================================================"
echo "  Ubuntu Fresh Install Auto-Configuration"
echo "================================================"
echo ""
print_status "Log file: $LOGFILE"
echo ""

# Update system
print_status "Updating system packages..."
sudo apt update >> "$LOGFILE" 2>&1
print_success "System packages updated"

# Install essential prerequisites
print_status "Installing essential build tools..."
sudo apt install -y build-essential curl wget git software-properties-common apt-transport-https ca-certificates gnupg lsb-release >> "$LOGFILE" 2>&1
print_success "Essential tools installed"

echo ""
echo "================================================"
echo "  Shell Environment Setup"
echo "================================================"
echo ""

# Install Zsh
if command_exists zsh; then
    print_skip "Zsh"
else
    print_status "Installing Zsh..."
    sudo apt install -y zsh >> "$LOGFILE" 2>&1
    print_success "Zsh installed"
fi

# Install Oh My Zsh
if [ -d "$HOME/.oh-my-zsh" ]; then
    print_skip "Oh My Zsh"
else
    print_status "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended >> "$LOGFILE" 2>&1
    print_success "Oh My Zsh installed"
fi

# Install Zsh plugins
print_status "Installing Zsh plugins..."

# zsh-autosuggestions
if [ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
    print_skip "zsh-autosuggestions"
else
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions >> "$LOGFILE" 2>&1
    print_success "zsh-autosuggestions installed"
fi

# zsh-syntax-highlighting
if [ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
    print_skip "zsh-syntax-highlighting"
else
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting >> "$LOGFILE" 2>&1
    print_success "zsh-syntax-highlighting installed"
fi

# Install Starship
if command_exists starship; then
    print_skip "Starship"
else
    print_status "Installing Starship prompt..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y >> "$LOGFILE" 2>&1
    print_success "Starship installed"
fi

# Configure Zsh
print_status "Configuring Zsh..."
if [ -f "$HOME/.zshrc" ]; then
    # Backup existing .zshrc
    cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d-%H%M%S)"
fi

# Update plugins in .zshrc (git plugin already has all the aliases!)
sed -i 's/^plugins=.*/plugins=(git docker docker-compose npm node python golang zsh-autosuggestions zsh-syntax-highlighting)/' "$HOME/.zshrc"

# Add Starship initialization if not present
if ! grep -q "starship init zsh" "$HOME/.zshrc"; then
    echo '' >> "$HOME/.zshrc"
    echo '# Initialize Starship prompt' >> "$HOME/.zshrc"
    echo 'eval "$(starship init zsh)"' >> "$HOME/.zshrc"
fi

# Add Python virtualenv configuration
if ! grep -q "VIRTUAL_ENV_DISABLE_PROMPT" "$HOME/.zshrc"; then
    echo '' >> "$HOME/.zshrc"
    echo '# Python virtualenv' >> "$HOME/.zshrc"
    echo 'export VIRTUAL_ENV_DISABLE_PROMPT=0' >> "$HOME/.zshrc"
fi

# Add history configuration to .zshrc
if ! grep -q "HISTSIZE" "$HOME/.zshrc"; then
    echo '' >> "$HOME/.zshrc"
    echo '# History configuration' >> "$HOME/.zshrc"
    echo 'HISTSIZE=10000' >> "$HOME/.zshrc"
    echo 'SAVEHIST=20000' >> "$HOME/.zshrc"
    echo 'setopt HIST_IGNORE_DUPS' >> "$HOME/.zshrc"
    echo 'setopt HIST_IGNORE_ALL_DUPS' >> "$HOME/.zshrc"
    echo 'setopt HIST_FIND_NO_DUPS' >> "$HOME/.zshrc"
    echo 'setopt HIST_SAVE_NO_DUPS' >> "$HOME/.zshrc"
    echo 'setopt SHARE_HISTORY' >> "$HOME/.zshrc"
    echo 'setopt APPEND_HISTORY' >> "$HOME/.zshrc"
fi

print_success "Zsh configured with plugins, Starship, and enhanced history"

# Create Starship config
if [ ! -f "$HOME/.config/starship.toml" ]; then
    mkdir -p "$HOME/.config"
    cat > "$HOME/.config/starship.toml" << 'EOF'
# Starship Configuration

# Add date and time to the prompt
[time]
disabled = false
format = '[$time]($style) '
style = "bold cyan"
time_format = "%d/%m/%Y %H:%M:%S"

# Disable cloud provider modules
[aws]
disabled = true

[gcloud]
disabled = true

[azure]
disabled = true

# Git branch configuration
[git_branch]
symbol = " "
style = "bold purple"

# Git status configuration
[git_status]
# Define the format for the entire git_status module
format = '([\[$all_status$ahead_behind\]]($style) )'
# Define the style (e.g., color and boldness)
style = "bold yellow"
# Define the symbols and format to show the count of each status
stashed = 'stash:${count}'
ahead = "⇡${count}"
behind = "⇣${count}"
diverged = "⇕⇡${ahead_count}⇣${behind_count}"
conflicted = "=${count}"
deleted = "✘${count}"
renamed = "»${count}"
modified = "!${count}"
staged = "+${count}"
untracked = "?${count}"

# Language/Tool configurations
[nodejs]
symbol = "⬢ "
style = "bold green"

[python]
symbol = "🐍 "
style = "bold yellow"

[golang]
symbol = "🐹 "
style = "bold cyan"

[docker_context]
symbol = "🐳 "
style = "bold blue"
EOF
    print_success "Starship config created"
else
    print_skip "Starship config already exists at ~/.config/starship.toml"
fi

# Set Zsh as default shell (optional, won't block script)
if [ "$SHELL" != "$(which zsh)" ]; then
    echo ""
    read -p "Do you want to set Zsh as your default shell? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Setting Zsh as default shell..."
        if chsh -s $(which zsh); then
            print_success "Zsh set as default shell (will apply on next login)"
        else
            print_warning "Could not set Zsh as default. Run manually later: chsh -s \$(which zsh)"
        fi
    else
        print_warning "Skipped setting Zsh as default. You can run it later with: chsh -s \$(which zsh)"
    fi
else
    print_skip "Zsh is already default shell"
fi

echo ""
echo "================================================"
echo "  Development Tools"
echo "================================================"
echo ""

# Git configuration
if command_exists git; then
    print_skip "Git"
    
    # Configure git if not configured
    if [ -z "$(git config --global user.name)" ]; then
        echo ""
        read -p "Enter your Git user name: " git_name
        git config --global user.name "$git_name"
        read -p "Enter your Git email: " git_email
        git config --global user.email "$git_email"
        print_success "Git configured"
    fi
fi

# Install NVM and Node.js
if [ -d "$HOME/.nvm" ]; then
    print_skip "NVM"
else
    print_status "Installing NVM (Node Version Manager)..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash >> "$LOGFILE" 2>&1
    
    # Load NVM
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    
    print_success "NVM installed"
fi

# Load NVM if not loaded
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Add NVM to .zshrc if not present
if ! grep -q "NVM_DIR" "$HOME/.zshrc"; then
    echo '' >> "$HOME/.zshrc"
    echo '# NVM (Node Version Manager)' >> "$HOME/.zshrc"
    echo 'export NVM_DIR="$HOME/.nvm"' >> "$HOME/.zshrc"
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> "$HOME/.zshrc"
    echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> "$HOME/.zshrc"
fi

# Install Node.js via NVM
if command_exists node; then
    print_skip "Node.js ($(node --version))"
else
    print_status "Installing Node.js LTS..."
    nvm install --lts >> "$LOGFILE" 2>&1
    nvm use --lts >> "$LOGFILE" 2>&1
    print_success "Node.js installed ($(node --version))"
fi

# Python and pip
if command_exists python3; then
    print_skip "Python3 ($(python3 --version))"
else
    print_status "Installing Python3..."
    sudo apt install -y python3 python3-pip python3-venv >> "$LOGFILE" 2>&1
    print_success "Python3 installed"
fi

# UV (Python package installer)
if command_exists uv; then
    print_skip "UV"
else
    print_status "Installing UV..."
    curl -LsSf https://astral.sh/uv/install.sh | sh >> "$LOGFILE" 2>&1
    
    # Add UV to PATH in .zshrc
    if ! grep -q ".local/bin" "$HOME/.zshrc"; then
        echo '' >> "$HOME/.zshrc"
        echo '# UV and local binaries' >> "$HOME/.zshrc"
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
    fi
    
    print_success "UV installed"
fi

# Go
if command_exists go; then
    print_skip "Go ($(go version))"
else
    print_status "Installing Go..."
    GO_VERSION="1.21.5"
    wget -q "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" >> "$LOGFILE" 2>&1
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf "go${GO_VERSION}.linux-amd64.tar.gz" >> "$LOGFILE" 2>&1
    rm "go${GO_VERSION}.linux-amd64.tar.gz"
    
    # Add Go to PATH in .zshrc if not present
    if ! grep -q "/usr/local/go/bin" "$HOME/.zshrc"; then
        echo '' >> "$HOME/.zshrc"
        echo '# Go' >> "$HOME/.zshrc"
        echo 'export PATH=$PATH:/usr/local/go/bin' >> "$HOME/.zshrc"
        echo 'export PATH=$PATH:$HOME/go/bin' >> "$HOME/.zshrc"
    fi
    
    print_success "Go installed"
fi

echo ""
echo "================================================"
echo "  IDEs and Editors"
echo "================================================"
echo ""

# VS Code
if command_exists code; then
    print_skip "VS Code"
else
    print_status "Installing VS Code..."
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
    sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
    rm -f packages.microsoft.gpg
    sudo apt update >> "$LOGFILE" 2>&1
    sudo apt install -y code >> "$LOGFILE" 2>&1
    print_success "VS Code installed"
fi

# Cursor
if command_exists cursor; then
    print_skip "Cursor"
else
    print_status "Installing Cursor..."
    print_warning "Cursor installation: Downloading AppImage to ~/Applications/cursor.appimage"
    mkdir -p "$HOME/Applications"
    wget -q "https://downloader.cursor.sh/linux/appImage/x64" -O "$HOME/Applications/cursor.appimage" >> "$LOGFILE" 2>&1
    chmod +x "$HOME/Applications/cursor.appimage"
    
    # Create desktop entry
    mkdir -p "$HOME/.local/share/applications"
    cat > "$HOME/.local/share/applications/cursor.desktop" << EOF
[Desktop Entry]
Name=Cursor
Exec=$HOME/Applications/cursor.appimage
Type=Application
Categories=Development;
EOF
    
    print_success "Cursor installed (AppImage in ~/Applications)"
fi

echo ""
echo "================================================"
echo "  DevOps & Database Tools"
echo "================================================"
echo ""

# Docker
if command_exists docker; then
    print_skip "Docker"
else
    print_status "Installing Docker..."
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update >> "$LOGFILE" 2>&1
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin >> "$LOGFILE" 2>&1
    
    # Add user to docker group
    sudo usermod -aG docker $USER
    print_success "Docker installed (logout/login required for group permissions)"
fi

# PostgreSQL
if command_exists psql; then
    print_skip "PostgreSQL ($(psql --version))"
else
    print_status "Installing PostgreSQL 18..."
    
    # Add PostgreSQL official repository for latest version
    sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
    wget -qO- https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo tee /etc/apt/trusted.gpg.d/pgdg.asc &>/dev/null
    
    sudo apt update >> "$LOGFILE" 2>&1
    sudo apt install -y postgresql-18 postgresql-contrib-18 >> "$LOGFILE" 2>&1
    
    sudo systemctl enable postgresql >> "$LOGFILE" 2>&1
    sudo systemctl start postgresql >> "$LOGFILE" 2>&1
    print_success "PostgreSQL 18 installed and started"
fi

# DBeaver
if command_exists dbeaver; then
    print_skip "DBeaver"
else
    print_status "Installing DBeaver..."
    sudo snap install dbeaver-ce >> "$LOGFILE" 2>&1
    print_success "DBeaver installed"
fi

# Postman
if command_exists postman; then
    print_skip "Postman"
else
    print_status "Installing Postman..."
    sudo snap install postman >> "$LOGFILE" 2>&1
    print_success "Postman installed"
fi

echo ""
echo "================================================"
echo "  Installation Complete!"
echo "================================================"
echo ""
print_success "All tools have been installed and configured!"
echo ""
echo "Installed versions:"
echo "-------------------"
[ -n "$(command -v zsh)" ] && echo "Zsh: $(zsh --version)"
[ -n "$(command -v starship)" ] && echo "Starship: $(starship --version)"
[ -n "$(command -v git)" ] && echo "Git: $(git --version)"
[ -n "$(command -v node)" ] && echo "Node: $(node --version)"
[ -n "$(command -v npm)" ] && echo "npm: $(npm --version)"
[ -n "$(command -v python3)" ] && echo "Python: $(python3 --version)"
[ -n "$(command -v uv)" ] && echo "UV: $(uv --version)"
[ -n "$(command -v go)" ] && echo "Go: $(go version)"
[ -n "$(command -v code)" ] && echo "VS Code: $(code --version | head -n 1)"
[ -n "$(command -v docker)" ] && echo "Docker: $(docker --version)"
[ -n "$(command -v psql)" ] && echo "PostgreSQL: $(psql --version)"
echo ""
echo "Configuration:"
echo "-------------------"
echo "✓ Zsh with Oh-My-Zsh and plugins"
echo "✓ Starship prompt with custom config"
echo "✓ Git plugin enabled (includes all git aliases: g, ga, gaa, gc, gp, etc.)"
echo "✓ Enhanced history (10k lines, deduplication, shared across sessions)"
echo "✓ Python virtualenv support"
echo "✓ NVM for Node.js version management"
echo "✓ Docker configured"
echo ""
echo "Next steps:"
echo "-------------------"
echo "1. Restart your terminal or run: exec zsh"
echo "2. Logout and login again for Docker group permissions"
echo "3. Try git aliases: g (git), ga (git add), gc (git commit), gp (git push)"
echo "4. Configure Starship: edit ~/.config/starship.toml"
echo "5. PostgreSQL access: sudo -u postgres psql"
echo "6. Check log file for details: $LOGFILE"
echo ""
print_status "Setup script completed successfully!"
