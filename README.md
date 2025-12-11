# Nix Configuration for macOS and Linux

A fully declarative and reproducible development environment using Nix flakes, nix-darwin, and home-manager. This configuration provides a cross-platform setup for macOS and Linux with consistent tooling and dotfiles.

## Features

- **Declarative Configuration**: All packages, settings, and dotfiles managed through Nix
- **Cross-Platform**: Works on macOS (Intel/Apple Silicon) and Linux (x86_64/aarch64)
- **Reproducible**: Same configuration produces identical environments
- **Atomic Updates**: Changes are transactional with easy rollback
- **Modern CLI Tools**: Batteries included with bat, eza, fd, ripgrep, fzf, and more
- **Full Development Setup**: Neovim, Tmux, ZSH with custom configurations
- **Git Integration**: Comprehensive git configuration with delta, lazygit, and aliases

## What's Included

### Core Tools
- **Shell**: ZSH with custom prompt, syntax highlighting, and autosuggestions
- **Editor**: Neovim with full configuration and LSP support
- **Terminal Multiplexer**: Tmux with vim-like keybindings
- **Version Control**: Git with delta diff viewer and extensive aliases

### Modern CLI Replacements
- `bat` → better cat with syntax highlighting
- `eza` → better ls with git integration
- `fd` → better find
- `ripgrep` → better grep
- `fzf` → fuzzy finder for everything
- `zoxide` → smarter cd command
- `btop` → better top

### Development Tools
- GitHub CLI (`gh`)
- Lazygit (git TUI)
- Multiple language servers for Neovim
- Direnv for per-project environments
- Code formatters (stylua, prettier, black, ruff)
- Linters (shellcheck, ruff)

### Python Development
- `uv` → extremely fast Python package installer and resolver
- `ruff` → blazing fast Python linter and formatter
- `black` → Python code formatter
- Multiple Python LSPs available

### Runtime Management
- `mise` → polyglot runtime manager (replaces asdf, fnm, rbenv, pyenv, etc.)
- Automatically activates in shell
- Project-specific tool versions via `.mise.toml`

### AI Development
- OpenCode CLI tool (if installed separately)
- Configuration managed via home-manager

### macOS Specific
- System defaults (keyboard, dock, finder, etc.)
- Homebrew integration for GUI apps:
  - Ghostty & WezTerm (terminal emulators)
  - Karabiner Elements (keyboard customization)
  - Aerospace (tiling window manager)
  - 1Password CLI

## Prerequisites

### macOS
- macOS 10.15 or later
- Xcode Command Line Tools:
  ```bash
  xcode-select --install
  ```

### Linux (non-NixOS)
- Any modern Linux distribution
- Sudo access for installation

### NixOS
- NixOS 23.05 or later
- See the [NixOS Installation](#on-nixos) section below for specific instructions

## Installation

### 1. Install Nix with Flakes Support

Using the Determinate Systems installer (recommended):

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Or use the official Nix installer:

```bash
sh <(curl -L https://nixos.org/nix/install) --daemon
```

Then enable flakes by adding to `~/.config/nix/nix.conf`:
```
experimental-features = nix-command flakes
```

### 2. Clone This Repository

```bash
git clone https://github.com/devinbfergy/nix-setup.git ~/.config/nix-setup
cd ~/.config/nix-setup
```

### 3. Customize Configuration

Before applying, update the following files with your personal information:

**Edit `flake.nix`:**
```nix
# Change username in the darwinConfigurations and homeConfigurations
username = "devin";  # Change to your username
```

**Edit `home/programs/git.nix`:**
```nix
userName = "Your Name";
userEmail = "your.email@example.com";
```

### 4. Apply Configuration

#### On macOS (with nix-darwin):

First-time setup:
```bash
# Install nix-darwin
nix run nix-darwin -- switch --flake ~/.config/nix-setup#macbook

# For Intel Macs, use:
# nix run nix-darwin -- switch --flake ~/.config/nix-setup#macbook-intel
```

Subsequent updates:
```bash
darwin-rebuild switch --flake ~/.config/nix-setup#macbook
```

#### On Linux (standalone home-manager):

First-time setup:
```bash
# Install home-manager
nix run home-manager/master -- switch --flake ~/.config/nix-setup#linux

# For ARM Linux, use:
# nix run home-manager/master -- switch --flake ~/.config/nix-setup#linux-arm
```

Subsequent updates:
```bash
home-manager switch --flake ~/.config/nix-setup#linux
```

#### On NixOS:

NixOS users have two options:

**Option 1: System-wide integration (Recommended)**

Integrate this configuration into your NixOS system configuration by importing the home-manager module:

1. First, clone this repository to your home directory:
   ```bash
   git clone https://github.com/devinbfergy/nix-setup.git ~/.config/nix-setup
   ```

2. Create or update your `/etc/nixos/flake.nix`:
   ```nix
   # /etc/nixos/flake.nix
   {
     description = "NixOS configuration";

     inputs = {
       nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
       home-manager = {
         url = "github:nix-community/home-manager";
         inputs.nixpkgs.follows = "nixpkgs";
       };
     };

     outputs = { self, nixpkgs, home-manager, ... }@inputs: {
       nixosConfigurations = {
         # Replace 'yourhostname' with your actual hostname
         yourhostname = nixpkgs.lib.nixosSystem {
           system = "x86_64-linux";  # or "aarch64-linux" for ARM
           modules = [
             ./configuration.nix
             home-manager.nixosModules.home-manager
             {
               home-manager.useGlobalPkgs = true;
               home-manager.useUserPackages = true;
               # Replace 'youruser' with your actual username
               home-manager.users.youruser = import /home/youruser/.config/nix-setup/home;
             }
           ];
         };
       };
     };
   }
   ```

3. Ensure your `/etc/nixos/configuration.nix` includes flakes support:
   ```nix
   # /etc/nixos/configuration.nix
   { config, pkgs, ... }:
   {
     # ... your existing configuration ...

     nix.settings.experimental-features = [ "nix-command" "flakes" ];
     
     # ... rest of your configuration ...
   }
   ```

4. Rebuild your system:
   ```bash
   sudo nixos-rebuild switch --flake /etc/nixos#yourhostname
   ```

**Option 2: Standalone home-manager (User-level only)**

Use the same approach as non-NixOS Linux distributions. This manages only your user environment without requiring system-level changes:

```bash
# Clone the repository
git clone https://github.com/devinbfergy/nix-setup.git ~/.config/nix-setup
cd ~/.config/nix-setup

# First-time setup
nix run home-manager/master -- switch --flake ~/.config/nix-setup#linux

# Subsequent updates
home-manager switch --flake ~/.config/nix-setup#linux
```

**Which option to choose?**

- Use **Option 1** if you want full integration with NixOS system management and prefer declarative system-wide configuration
- Use **Option 2** if you only want to manage your user environment or don't have root access to modify system configuration

### 5. Set ZSH as Default Shell

```bash
# On macOS
chsh -s /run/current-system/sw/bin/zsh

# On Linux
chsh -s $(which zsh)
```

Restart your terminal or log out and back in for changes to take effect.

## Usage

### Updating Your Configuration

1. Edit any `.nix` files in this repository
2. Apply changes:
   ```bash
   # macOS
   darwin-rebuild switch --flake ~/.config/nix-setup#macbook
   
   # Linux (standalone home-manager)
   home-manager switch --flake ~/.config/nix-setup#linux
   
   # NixOS (system-wide integration)
   sudo nixos-rebuild switch --flake /etc/nixos#yourhostname
   
   # NixOS (standalone home-manager)
   home-manager switch --flake ~/.config/nix-setup#linux
   ```

### Adding Packages

Add packages to `home/default.nix` in the `home.packages` list:

```nix
home.packages = with pkgs; [
  # Add your packages here
  htop
  jq
  # ...
];
```

### Rolling Back Changes

If something breaks, you can easily rollback:

```bash
# macOS
darwin-rebuild switch --rollback

# Linux (standalone home-manager)
home-manager generations
home-manager switch --switch-generation <number>

# NixOS (system-wide integration)
sudo nixos-rebuild switch --rollback
# Or select previous generation from boot menu

# NixOS (standalone home-manager)
home-manager generations
home-manager switch --switch-generation <number>
```

### Updating Flake Inputs

Update nixpkgs and other inputs:

```bash
nix flake update
```

Then rebuild your system.

## Directory Structure

```
.
├── flake.nix              # Main flake configuration
├── flake.lock             # Locked dependency versions
├── darwin/                # macOS-specific configuration
│   └── default.nix        # nix-darwin settings
├── home/                  # Home-manager configuration
│   ├── default.nix        # Main home config
│   └── programs/          # Program-specific configs
│       ├── git.nix
│       ├── zsh.nix
│       ├── tmux.nix
│       └── neovim.nix
├── config/                # Dotfiles (symlinked by home-manager)
│   ├── nvim/
│   ├── tmux/
│   ├── zsh/
│   └── ...
└── bin/                   # Custom scripts (added to PATH)
```

## Configuration Details

### ZSH

- Custom prompt with git integration
- Syntax highlighting and autosuggestions
- Extensive aliases for common commands
- FZF integration for fuzzy finding
- Custom functions in `config/zsh/`

### Tmux

- Prefix changed to `Ctrl-a`
- Vim-like keybindings for pane navigation
- Mouse support enabled
- Persistent sessions with tmux-resurrect
- Custom status bar

### Neovim

- Full LSP support for multiple languages
- Lazy.nvim for plugin management
- Tree-sitter for syntax highlighting
- Telescope for fuzzy finding
- Git integration with fugitive
- All existing plugins and configurations preserved

### Git

- Custom aliases for common workflows
- Delta for beautiful diffs
- Lazygit for visual git operations
- Pre-configured for optimal developer experience

## Troubleshooting

### Command Not Found After Installation

Restart your terminal or source your shell:
```bash
source ~/.zshrc
```

### Neovim Plugins Not Working

Run inside Neovim:
```vim
:Lazy sync
```

### Homebrew Apps Not Installing (macOS)

Ensure you have Homebrew installed first:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Then rebuild:
```bash
darwin-rebuild switch --flake ~/.config/nix-setup#macbook
```

### File Permission Issues

Some scripts in `bin/` may need executable permissions:
```bash
chmod +x ~/.config/nix-setup/bin/*
```

### Changes Not Taking Effect

Make sure you're in the right directory when rebuilding:
```bash
cd ~/.config/nix-setup
darwin-rebuild switch --flake .#macbook
```

## Customization

### macOS System Defaults

Edit `darwin/default.nix` to customize macOS system settings. The configuration includes settings for:
- Dock behavior and appearance
- Finder preferences
- Keyboard repeat rates
- Trackpad settings
- Screenshot location

### Adding Your Own Scripts

Place executable scripts in the `bin/` directory. They'll automatically be added to your PATH.

### Per-Machine Configuration

Create a `~/.localrc` file for machine-specific settings that shouldn't be in version control:

```bash
# ~/.localrc
export CUSTOM_VAR="value"
alias work="cd ~/Work"
```

This file is automatically sourced by ZSH if it exists.

## Project-Specific Development Environments

Use direnv and nix-shell for per-project environments:

Create a `shell.nix` or `flake.nix` in your project:

```nix
# shell.nix
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    nodejs
    python3
    # Add project-specific tools
  ];
}
```

Then create `.envrc`:
```bash
use nix
```

Run `direnv allow` and the environment activates automatically when you enter the directory.

## Contributing

This is a personal configuration, but feel free to fork and adapt it to your needs. If you find bugs or have improvements, issues and pull requests are welcome.

## Resources

- [Nix Manual](https://nixos.org/manual/nix/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [nix-darwin Manual](https://daiderd.com/nix-darwin/manual/)
- [Nix Flakes](https://nixos.wiki/wiki/Flakes)

## License

MIT License - See LICENSE file for details.

## Acknowledgments

This configuration is based on patterns from the Nix community and inspired by:
- [nicknisi/dotfiles](https://github.com/nicknisi/dotfiles) - Original dotfiles structure
- Various Nix community configurations
