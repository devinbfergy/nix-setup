#!/usr/bin/env bash
#
# Bootstrap script for Nix configuration
# This script installs Nix and applies the configuration

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info() {
    echo -e "${BLUE}==>${NC} $1"
}

success() {
    echo -e "${GREEN}==>${NC} $1"
}

error() {
    echo -e "${RED}==>${NC} $1"
}

warn() {
    echo -e "${YELLOW}==>${NC} $1"
}

# Detect OS
OS="unknown"
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
else
    error "Unsupported operating system: $OSTYPE"
    exit 1
fi

# Detect architecture
ARCH=$(uname -m)
if [[ "$ARCH" == "x86_64" ]]; then
    ARCH_TYPE="x86_64"
elif [[ "$ARCH" == "arm64" ]] || [[ "$ARCH" == "aarch64" ]]; then
    ARCH_TYPE="aarch64"
else
    error "Unsupported architecture: $ARCH"
    exit 1
fi

info "Detected OS: $OS ($ARCH_TYPE)"

# Install Xcode Command Line Tools on macOS
if [[ "$OS" == "macos" ]]; then
    if ! xcode-select -p &>/dev/null; then
        info "Installing Xcode Command Line Tools..."
        xcode-select --install
        warn "Please complete the Xcode Command Line Tools installation and run this script again."
        exit 0
    fi
fi

# Check if Nix is already installed
if command -v nix &>/dev/null; then
    success "Nix is already installed"
else
    info "Installing Nix..."
    
    # Ask user which installer to use
    echo ""
    echo "Choose Nix installer:"
    echo "1) Determinate Systems Installer (recommended, includes flakes)"
    echo "2) Official Nix Installer"
    read -p "Enter choice [1-2]: " installer_choice
    
    case $installer_choice in
        1)
            info "Using Determinate Systems installer..."
            curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
            ;;
        2)
            info "Using official Nix installer..."
            sh <(curl -L https://nixos.org/nix/install) --daemon
            
            # Enable flakes
            info "Enabling flakes..."
            mkdir -p ~/.config/nix
            cat > ~/.config/nix/nix.conf <<EOF
experimental-features = nix-command flakes
EOF
            ;;
        *)
            error "Invalid choice"
            exit 1
            ;;
    esac
    
    success "Nix installed successfully"
fi

# Source Nix
if [[ "$OS" == "macos" ]]; then
    if [[ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]]; then
        source '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
    fi
elif [[ "$OS" == "linux" ]]; then
    if [[ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]]; then
        source '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
    fi
fi

# Clone or update repository
REPO_DIR="$HOME/.config/nix-setup"
if [[ -d "$REPO_DIR" ]]; then
    info "Repository already exists at $REPO_DIR"
    read -p "Update repository? [y/N]: " update_repo
    if [[ "$update_repo" =~ ^[Yy]$ ]]; then
        info "Updating repository..."
        cd "$REPO_DIR"
        git pull
    fi
else
    info "Cloning repository..."
    git clone https://github.com/devinbfergy/nix-setup.git "$REPO_DIR"
fi

cd "$REPO_DIR"

# Get username
CURRENT_USER=$(whoami)
read -p "Enter your username [$CURRENT_USER]: " username
username=${username:-$CURRENT_USER}

# Get Git information
read -p "Enter your full name for Git: " git_name
read -p "Enter your email for Git: " git_email

# Update configuration files
info "Updating configuration..."

# Update git.nix
if [[ -f "home/programs/git.nix" ]]; then
    if [[ "$OS" == "macos" ]]; then
        sed -i '' "s/userName = .*/userName = \"$git_name\";/" home/programs/git.nix
        sed -i '' "s/userEmail = .*/userEmail = \"$git_email\";/" home/programs/git.nix
    else
        sed -i "s/userName = .*/userName = \"$git_name\";/" home/programs/git.nix
        sed -i "s/userEmail = .*/userEmail = \"$git_email\";/" home/programs/git.nix
    fi
fi

# Determine configuration name
if [[ "$OS" == "macos" ]]; then
    if [[ "$ARCH_TYPE" == "aarch64" ]]; then
        CONFIG_NAME="macbook"
    else
        CONFIG_NAME="macbook-intel"
    fi
    
    info "Installing nix-darwin..."
    
    # First-time nix-darwin installation
    if ! command -v darwin-rebuild &>/dev/null; then
        info "Running initial nix-darwin installation..."
        nix run nix-darwin -- switch --flake "$REPO_DIR#$CONFIG_NAME"
    else
        info "Rebuilding system..."
        darwin-rebuild switch --flake "$REPO_DIR#$CONFIG_NAME"
    fi
    
    success "macOS system configured with nix-darwin"
    
    # Prompt to change shell
    echo ""
    info "To use ZSH as your default shell, run:"
    echo "  chsh -s /run/current-system/sw/bin/zsh"
    
elif [[ "$OS" == "linux" ]]; then
    if [[ "$ARCH_TYPE" == "aarch64" ]]; then
        CONFIG_NAME="linux-arm"
    else
        CONFIG_NAME="linux"
    fi
    
    info "Installing home-manager..."
    
    # First-time home-manager installation
    if ! command -v home-manager &>/dev/null; then
        info "Running initial home-manager installation..."
        nix run home-manager/master -- switch --flake "$REPO_DIR#$CONFIG_NAME"
    else
        info "Rebuilding home configuration..."
        home-manager switch --flake "$REPO_DIR#$CONFIG_NAME"
    fi
    
    success "Linux home environment configured with home-manager"
    
    # Prompt to change shell
    echo ""
    info "To use ZSH as your default shell, run:"
    echo "  chsh -s \$(which zsh)"
fi

echo ""
success "Installation complete!"
echo ""
info "Next steps:"
echo "  1. Restart your terminal or run: source ~/.zshrc"
echo "  2. For Neovim, open nvim and run: :Lazy sync"
if [[ "$OS" == "macos" ]]; then
    echo "  3. To update in the future, run: darwin-rebuild switch --flake ~/.config/nix-setup#$CONFIG_NAME"
else
    echo "  3. To update in the future, run: home-manager switch --flake ~/.config/nix-setup#$CONFIG_NAME"
fi
echo ""
info "Configuration location: $REPO_DIR"
info "Read the README.md for more information: $REPO_DIR/README.md"
