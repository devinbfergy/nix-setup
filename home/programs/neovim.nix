{ config, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    
    # Set as default editor
    defaultEditor = true;
    
    # Additional packages needed for neovim plugins
    extraPackages = with pkgs; [
      # Language servers
      nil  # Nix LSP
      lua-language-server
      nodePackages.typescript-language-server
      nodePackages.vscode-langservers-extracted  # HTML, CSS, JSON, ESLint
      nodePackages.yaml-language-server
      nodePackages.bash-language-server
      
      # Formatters
      stylua
      nodePackages.prettier
      black  # Python formatter
      ruff   # Fast Python linter and formatter
      
      # Linters
      shellcheck
      
      # Tools
      ripgrep
      fd
      tree-sitter
      gcc  # Required for treesitter
    ];
    
    # Python provider (for plugins that need it)
    withPython3 = true;
    withNodeJs = true;
    withRuby = false;
  };
  
  # Symlink neovim config from dotfiles
  # This allows lazy.nvim and the existing config to work as-is
  home.file.".config/nvim" = {
    source = config.lib.file.mkOutOfStoreSymlink 
      "${config.home.homeDirectory}/.config/nix-setup/config/nvim";
    recursive = true;
  };
  
  # Additional tool configurations for neovim
  home.packages = with pkgs; [
    # Clipboard support
    xclip  # For Linux
    wl-clipboard  # For Wayland
  ];
}
