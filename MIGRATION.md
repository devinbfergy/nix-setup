# Migration Summary: Dotfiles to Nix

## What Was Converted

This repository represents a complete conversion from a traditional dotfiles setup to a fully declarative Nix-based configuration.

### Original Repository
- **Source**: https://github.com/devinbfergy/dotfiles
- **Approach**: Imperative shell scripts with manual symlinking
- **Package Manager**: Homebrew (macOS)
- **Configuration Management**: Custom `dot` command

### New Nix Setup
- **Approach**: Declarative configuration with Nix flakes
- **Package Manager**: Nix (with Homebrew for GUI apps on macOS)
- **Configuration Management**: home-manager + nix-darwin
- **Reproducibility**: Full system state in version control

## Architecture

```
nix-setup/
├── flake.nix                    # Main entry point, defines all configurations
├── flake.lock                   # Locked dependencies for reproducibility
├── install.sh                   # Bootstrap script
├── README.md                    # Comprehensive documentation
│
├── darwin/
│   └── default.nix              # macOS system configuration via nix-darwin
│                                  - System packages
│                                  - macOS defaults (dock, finder, keyboard)
│                                  - Homebrew integration for GUI apps
│
├── home/
│   ├── default.nix              # Main home-manager configuration
│   │                              - User packages
│   │                              - Environment variables
│   │                              - XDG directories
│   └── programs/
│       ├── git.nix              # Git configuration with all aliases
│       ├── zsh.nix              # ZSH with plugins and custom config
│       ├── tmux.nix             # Tmux configuration
│       └── neovim.nix           # Neovim setup with LSP
│
├── config/                      # Original dotfiles (symlinked by home-manager)
│   ├── nvim/                    # Full Neovim configuration
│   ├── tmux/                    # Tmux themes and settings
│   ├── zsh/                     # ZSH functions, aliases, prompt
│   ├── git/                     # Additional git configs
│   ├── ghostty/                 # Terminal emulator configs
│   ├── wezterm/
│   ├── karabiner/               # Keyboard customization
│   └── ...
│
└── bin/                         # Custom scripts (added to PATH)
    ├── dot                      # Original dot command (mostly obsolete)
    ├── git-*                    # Git helper scripts
    └── ...                      # Various utility scripts
```

## Package Migration

### Successfully Migrated to Nix

All CLI tools from the Brewfile are now managed by Nix:

**Core Utilities:**
- git, vim, bash, zsh, grep
- bat, eza, fd, ripgrep, fzf
- neovim, tmux, lazygit
- gh, git-delta, glow
- jq, tree, wget, btop
- python3, nodejs
- shellcheck, stylua
- zoxide, sesh, entr
- gnupg, cloc, wdiff

**Development Tools:**
- Language servers for Nix, Lua, TypeScript, etc.
- Formatters (prettier, black, stylua)
- Linters (shellcheck)

### Kept in Homebrew (macOS GUI Apps)

These remain in Homebrew via nix-darwin's Homebrew integration:
- ghostty (terminal emulator)
- wezterm (terminal emulator)
- 1password-cli
- karabiner-elements (keyboard customizer)
- aerospace (tiling window manager)
- borders (window borders)
- noti (notifications)
- trash (better rm)

### Fonts

Migrated to Nix:
- NerdFontsSymbolsOnly
- Monaspace

## Configuration Features

### Git (home/programs/git.nix)
- All 50+ aliases from original config
- Delta integration for beautiful diffs
- Full color configuration
- Lazygit integration
- Machine-specific settings via `~/.gitconfig-local`

### ZSH (home/programs/zsh.nix)
- Syntax highlighting via home-manager
- Autosuggestions enabled
- FZF integration
- Custom prompt (from original dotfiles)
- History configuration
- Aliases for modern tools (bat, eza, etc.)
- Sources original ZSH files from config/zsh/

### Tmux (home/programs/tmux.nix)
- Prefix: Ctrl-a
- Vim-like keybindings
- Mouse support
- 24-bit color
- Tmux resurrect and continuum plugins
- Sources original tmux.conf for additional customization

### Neovim (home/programs/neovim.nix)
- Full LSP support (Nix, Lua, TypeScript, etc.)
- Tree-sitter
- Symlinks original config from config/nvim/
- Lazy.nvim works as-is
- All plugins preserved

### macOS System Defaults (darwin/default.nix)
- Keyboard: Caps Lock → Control, fast key repeat
- Dock: Auto-hide, no recents, minimal size
- Finder: Show all files, extensions, path bar
- Dark mode enabled
- Touch ID for sudo
- Screenshot location configured

## How to Use

### Installation
```bash
# Run the bootstrap script
bash <(curl -L https://raw.githubusercontent.com/devinbfergy/nix-setup/main/install.sh)
```

### Daily Usage

**Update system:**
```bash
# macOS
darwin-rebuild switch --flake ~/.config/nix-setup#macbook

# Linux
home-manager switch --flake ~/.config/nix-setup#linux
```

**Add a package:**
Edit `home/default.nix`, add package to `home.packages`, then rebuild.

**Rollback:**
```bash
darwin-rebuild switch --rollback
```

**Update packages:**
```bash
cd ~/.config/nix-setup
nix flake update
darwin-rebuild switch --flake .#macbook
```

## Key Improvements Over Original

1. **Reproducibility**: Same config → identical environment across machines
2. **Atomic Updates**: Changes are transactional, easy rollback
3. **Cross-Platform**: Single config for macOS (Intel/ARM) and Linux
4. **No Manual Linking**: home-manager handles all symlinking
5. **Version Locking**: flake.lock ensures consistent package versions
6. **Binary Caching**: Fast installations from cache.nixos.org
7. **Declarative State**: Entire system configuration in version control
8. **Project Environments**: Easy per-project dev shells with direnv

## What's Different from Traditional Dotfiles

### Obsoleted Features
- **`dot` command**: Most functionality replaced by nix-darwin/home-manager
  - `dot link`: Now done automatically by home-manager
  - `dot backup`: Nix allows easy rollback
  - `dot homebrew`: Managed by nix-darwin
  
### New Capabilities
- **Flake-based**: Reproducible, locked dependencies
- **Multiple Configurations**: Easy per-machine configs in one repo
- **System Defaults**: macOS settings in version control
- **Development Shells**: Per-project environments without system pollution

### Preserved Features
- All original dotfiles in config/ directory
- All custom scripts in bin/ directory
- ZSH prompt and functions
- Neovim configuration with lazy.nvim
- Tmux themes and keybindings
- Git aliases and workflows

## Migration Path for New Machines

1. **macOS Setup:**
   ```bash
   # Install Nix
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
   
   # Clone and apply
   git clone https://github.com/devinbfergy/nix-setup ~/.config/nix-setup
   cd ~/.config/nix-setup
   nix run nix-darwin -- switch --flake .#macbook
   
   # Set shell
   chsh -s /run/current-system/sw/bin/zsh
   ```

2. **Linux Setup:**
   ```bash
   # Install Nix
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
   
   # Clone and apply
   git clone https://github.com/devinbfergy/nix-setup ~/.config/nix-setup
   cd ~/.config/nix-setup
   nix run home-manager/master -- switch --flake .#linux
   
   # Set shell
   chsh -s $(which zsh)
   ```

## Per-Project Development

Instead of fnm/rbenv, use Nix shells:

```nix
# flake.nix in your project
{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  
  outputs = { nixpkgs, ... }: {
    devShells.x86_64-darwin.default = nixpkgs.legacyPackages.x86_64-darwin.mkShell {
      buildInputs = [
        nixpkgs.legacyPackages.x86_64-darwin.nodejs_20
        nixpkgs.legacyPackages.x86_64-darwin.python311
      ];
    };
  };
}
```

With direnv: `echo "use flake" > .envrc && direnv allow`

## Testing

The configuration can be tested in a VM or container before applying to real hardware.

## Future Enhancements

Potential additions:
- [ ] NixOS configuration for full Linux systems
- [ ] Secrets management with sops-nix or agenix
- [ ] Automated backups integration
- [ ] Custom Nix packages for missing tools
- [ ] CI/CD to validate changes
- [ ] Multiple user profiles
- [ ] Work vs personal configurations

## Resources

- [Nix Manual](https://nixos.org/manual/nix/stable/)
- [Home Manager](https://nix-community.github.io/home-manager/)
- [nix-darwin](https://github.com/LnL7/nix-darwin)
- [Original Dotfiles](https://github.com/devinbfergy/dotfiles)

## Support

For issues or questions:
1. Check README.md for troubleshooting
2. Review the Nix manuals
3. Check Nix community resources
4. File an issue on the repository
