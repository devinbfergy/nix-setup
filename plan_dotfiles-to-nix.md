# Plan: Convert Dotfiles to Nix Configuration

## Overview
Convert the existing dotfiles repository into a comprehensive Nix configuration that works cross-platform (Linux, macOS) using:
- **nix-darwin** for macOS system configuration
- **home-manager** for user-level dotfiles and packages
- **flakes** for reproducible, declarative configuration

## Architecture

```
nix-setup/
├── flake.nix                 # Main entry point, defines outputs for different systems
├── flake.lock                # Lock file for reproducible builds
├── darwin/                   # macOS-specific configuration
│   ├── default.nix          # Main darwin configuration
│   └── homebrew.nix         # Homebrew packages not in nixpkgs
├── home/                     # home-manager configuration
│   ├── default.nix          # Main home configuration
│   ├── packages.nix         # User packages
│   ├── programs/            # Program-specific configs
│   │   ├── zsh.nix
│   │   ├── tmux.nix
│   │   ├── neovim.nix
│   │   ├── git.nix
│   │   └── ...
│   └── shell.nix            # Shell environment
├── modules/                  # Shared Nix modules
│   ├── common.nix           # Cross-platform settings
│   └── fonts.nix            # Font configuration
└── config/                   # Dotfiles (symlinked by home-manager)
    ├── nvim/
    ├── tmux/
    ├── zsh/
    ├── git/
    └── ...
```

## Phase 1: Core Infrastructure

### 1.1 Create flake.nix
- Define inputs (nixpkgs, nix-darwin, home-manager)
- Set up outputs for:
  - `darwinConfigurations` (macOS)
  - `nixosConfigurations` (Linux, future)
  - `homeConfigurations` (standalone home-manager)
- Enable flakes and nix-command features

### 1.2 Set up nix-darwin (macOS)
- System-level packages
- macOS system defaults (from dot macos defaults)
- Homebrew integration for unavailable packages

### 1.3 Set up home-manager
- User packages from Brewfile
- Shell configuration (zsh)
- XDG directory structure

## Phase 2: Package Migration

### 2.1 Core utilities (from Brewfile)
Map Homebrew packages to Nix equivalents:
- git, vim, bash, zsh, grep → nixpkgs
- bat, eza, fd, fzf, ripgrep → nixpkgs
- neovim, tmux, lazygit → nixpkgs
- gh, glow, jq, tree, wget → nixpkgs
- btop, entr, highlight → nixpkgs
- git-delta, shellcheck, stylua → nixpkgs
- zoxide, sesh → nixpkgs
- gnupg → nixpkgs
- python, ruby (via rbenv) → nixpkgs
- fnm (node) → nixpkgs or use nodejs directly

### 2.2 macOS-specific packages
Keep in Homebrew via nix-darwin:
- ghostty, wezterm (GUI apps)
- karabiner-elements
- aerospace (tiling WM)
- 1password-cli
- borders, noti, trash
- Fonts (or use nixpkgs fonts)

### 2.3 Linux-specific packages
- xclip → nixpkgs

## Phase 3: Dotfiles Configuration

### 3.1 ZSH configuration
- Source existing zsh config from config/zsh/
- Set up zsh plugins via home-manager
- Configure prompt
- Set environment variables

### 3.2 Neovim configuration
- Symlink config/nvim/ to ~/.config/nvim
- Ensure lazy.nvim works with Nix
- Handle plugin management (keep lazy.nvim or migrate to Nix)

### 3.3 Tmux configuration
- Source config/tmux/ files
- Install tmux plugins if needed

### 3.4 Git configuration
- Import config/git/ settings
- Set up git-delta integration
- Configure gitconfig

### 3.5 Terminal emulator configs
- WezTerm: config/wezterm/
- Ghostty: config/ghostty/
- Kitty: config/kitty/

### 3.6 Other tools
- aerospace: config/aerospace/
- karabiner: config/karabiner/
- lazygit: config/lazygit/
- ripgrep: config/ripgrep/

## Phase 4: Custom Scripts and Binaries

### 4.1 Bin directory
- Copy bin/ scripts
- Make available in PATH via home-manager

### 4.2 Dot command
- Port the custom "dot" command to Nix where applicable
- Some functionality becomes obsolete with Nix (linking, backup)

## Phase 5: System Integration

### 5.1 macOS defaults
- Port macos defaults settings to nix-darwin's system.defaults
- Custom defaults via system.activationScripts

### 5.2 Shell setup
- Default shell configuration
- Terminal info files

### 5.3 Fonts
- Install fonts via home-manager or nix-darwin
- font-symbols-only-nerd-font
- font-monaspace

## Phase 6: Documentation and Scripts

### 6.1 Installation script
Create simple bootstrap script:
```bash
# Install Nix
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# Clone repo
git clone https://github.com/devinbfergy/nix-setup

# Apply configuration
cd nix-setup
darwin-rebuild switch --flake .#macbook  # macOS
home-manager switch --flake .#user       # Linux/standalone
```

### 6.2 README
- Explain Nix-based approach
- Installation instructions per platform
- How to add packages
- How to modify configurations
- Troubleshooting

## Phase 7: Testing and Refinement

### 7.1 macOS testing
- Test full installation on clean macOS
- Verify all programs work
- Test dotfiles are correctly symlinked

### 7.2 Linux testing
- Test home-manager standalone on Linux
- Verify cross-platform packages work
- Ensure Linux-specific packages install

## Benefits of Nix Approach

1. **Reproducibility**: Same config produces same environment
2. **Atomic updates**: Changes are transactional, can rollback
3. **Cross-platform**: One config for Linux/macOS with platform-specific overrides
4. **No manual symlinking**: home-manager handles dotfile management
5. **Declarative**: Entire system state in version control
6. **Isolated environments**: No global pollution, per-project shells
7. **Binary caching**: Fast installations from cache.nixos.org

## Migration Strategy

1. Start with minimal flake.nix
2. Migrate packages incrementally
3. Test each phase before moving forward
4. Keep existing dotfiles working during transition
5. Maintain both systems briefly for safety
6. Document any platform-specific issues

## Key Nix Concepts to Use

- **Flakes**: Modern Nix feature for reproducible configs
- **home-manager**: Manage user environment and dotfiles
- **nix-darwin**: macOS system configuration
- **overlays**: Customize or add packages
- **modules**: Organize configuration into logical units
- **options**: Create custom configuration options

## Outstanding Questions

1. Keep lazy.nvim for Neovim plugins or use Nix?
   - Recommendation: Keep lazy.nvim (simpler, more flexible)
2. Font installation method?
   - Use home.packages with nerdfonts overlay
3. Handle secrets (git config, etc)?
   - Use sops-nix or agenix for secrets management
4. Node/Ruby version management?
   - Use Nix shells per project instead of fnm/rbenv
