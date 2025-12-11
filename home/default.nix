{ config, pkgs, username, ... }:

{
  imports = [
    ./programs/zsh.nix
    ./programs/git.nix
    ./programs/tmux.nix
    ./programs/neovim.nix
  ];

  # Home Manager needs a bit of information about you and the paths it should manage
  home = {
    username = username;
    homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";
    stateVersion = "24.11";

    # Environment variables
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      PAGER = "less";
      LESS = "-R";
      CODE_DIR = "$HOME/Developer";
      DOTFILES = "$HOME/.config/nix-setup";
    };

    # User packages
    packages = with pkgs; [
      # Core utilities
      bash
      coreutils
      findutils
      gnugrep
      gnused
      gawk
      
      # Modern CLI tools
      bat           # Better cat
      eza           # Better ls
      fd            # Better find
      ripgrep       # Better grep
      fzf           # Fuzzy finder
      zoxide        # Better cd
      
      # Development tools
      gh            # GitHub CLI
      git-delta     # Better git diff
      lazygit       # Git TUI
      
      # File tools
      tree          # Directory tree viewer
      entr          # File watcher
      
      # Text processing
      jq            # JSON processor
      glow          # Markdown viewer
      highlight     # Syntax highlighter
      
      # System tools
      btop          # System monitor
      wget          # Downloader
      
      # Shell utilities
      gum           # Fancy UI utilities
      
      # Code quality
      shellcheck    # Shell script linter
      stylua        # Lua formatter
      ruff          # Python linter and formatter
      
      # Programming languages and tools
      python3
      nodejs
      uv            # Fast Python package installer
      mise          # Polyglot runtime manager (replaces asdf, fnm, rbenv)
      
      # Misc
      gnupg         # GPG
      cloc          # Lines of code counter
      wdiff         # Word diff
      sesh          # Session manager
    ] ++ (if pkgs.stdenv.isLinux then [
      # Linux-specific packages
      xclip         # Clipboard access
    ] else []);

    # Create commonly used directories
    file = {
      "Developer/.keep".text = "";
    };
    
    # Add custom bin scripts to PATH
    sessionPath = [
      "$HOME/.config/nix-setup/bin"
      "$HOME/.opencode/bin"  # OpenCode CLI
    ];
  };

  # XDG Base Directory Specification
  xdg = {
    enable = true;
    
    configHome = "${config.home.homeDirectory}/.config";
    dataHome = "${config.home.homeDirectory}/.local/share";
    cacheHome = "${config.home.homeDirectory}/.cache";
    stateHome = "${config.home.homeDirectory}/.local/state";
  };

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

  # Enable direnv for project-specific environments
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  # Enable starship prompt (alternative to custom prompt)
  # We'll disable this initially and use the custom ZSH prompt
  programs.starship = {
    enable = false;
  };

  # FZF configuration
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    defaultOptions = [
      "--height 40%"
      "--border"
      "--layout=reverse"
      "--info=inline"
    ];
  };

  # Zoxide configuration
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # Bat configuration
  programs.bat = {
    enable = true;
    config = {
      theme = "TwoDark";
      pager = "less -FR";
    };
  };

  # Eza aliases
  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    git = true;
    icons = "auto";
  };

  # Mise configuration (polyglot runtime manager with Nix integration)
  programs.mise = {
    enable = true;
    enableZshIntegration = true;
    
    # Global settings
    globalConfig = {
      tools = {
        # Global tools can be defined here, but we prefer using Nix for globals
        # and mise for project-specific versions
      };
      
      settings = {
        experimental = true;
        verbose = false;
        
        # Enable Nix integration - mise will use Nix packages when available
        # This provides the speed of Nix with the flexibility of mise
        use_nix = true;
        
        # Task runner
        task_runner = true;
        
        # Python settings
        python = {
          uv_venv_auto = true;
        };
        
        # Trust our developer directory
        trusted_config_paths = [
          "~/Developer/"
          "~/.config/nix-setup/"
        ];
      };
    };
  };
  
  # Symlink mise config as well (for any manual edits)
  home.file.".config/mise/config.toml".source = 
    config.lib.file.mkOutOfStoreSymlink 
      "${config.home.homeDirectory}/.config/nix-setup/config/mise/config.toml";

  # OpenCode configuration
  home.file.".config/opencode/opencode.json".source = 
    config.lib.file.mkOutOfStoreSymlink 
      "${config.home.homeDirectory}/.config/nix-setup/config/opencode/opencode.json";
}
