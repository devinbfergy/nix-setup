{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    
    dotDir = ".config/zsh";
    
    history = {
      size = 50000;
      save = 50000;
      path = "${config.xdg.dataHome}/zsh/history";
      ignoreDups = true;
      ignoreSpace = true;
      expireDuplicatesFirst = true;
      share = true;
    };
    
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      PAGER = "less";
      LESS = "-R";
      CODE_DIR = "$HOME/Developer";
    };
    
    shellAliases = {
      # Modern replacements
      cat = "bat";
      ls = "eza";
      ll = "eza -l";
      la = "eza -la";
      lt = "eza --tree";
      
      # Git aliases
      g = "git";
      gs = "git status";
      gd = "git diff";
      gc = "git commit";
      gp = "git push";
      gl = "git pull";
      gco = "git checkout";
      gb = "git branch";
      
      # Navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      
      # Vim
      v = "nvim";
      vim = "nvim";
      vi = "nvim";
      
      # Utilities
      h = "history";
      c = "clear";
      
      # Better defaults
      grep = "grep --color=auto";
      mkdir = "mkdir -p";
      
      # Tmux
      t = "tmux";
      ta = "tmux attach";
      tls = "tmux list-sessions";
      
      # Quick cd to code directory
      code = "cd $CODE_DIR";
    };
    
    initExtra = ''
      # Source ZSH configuration files from the config directory
      DOTFILES_CONFIG="${config.home.homeDirectory}/.config/nix-setup/config"
      
      # Set up zsh functions
      if [[ -d "$DOTFILES_CONFIG/zsh" ]]; then
        # Add custom functions to fpath
        fpath=("$DOTFILES_CONFIG/zsh/functions" $fpath)
        
        # Autoload custom functions
        autoload -Uz $DOTFILES_CONFIG/zsh/functions/*(:t)
      fi
      
      # Source additional ZSH configuration if it exists
      for zsh_source in $DOTFILES_CONFIG/zsh/*.zsh; do
        [[ -f "$zsh_source" ]] && source "$zsh_source"
      done
      
      # Custom prompt
      # This will be replaced by the prompt from your dotfiles
      setopt PROMPT_SUBST
      
      # Git prompt function
      git_prompt_info() {
        local branch
        if branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null); then
          if [[ "$branch" == "HEAD" ]]; then
            branch="detached*"
          fi
          
          local git_status
          git_status=$(git status --porcelain 2>/dev/null)
          
          local git_state=""
          if [[ -n "$git_status" ]]; then
            git_state="*"
          fi
          
          echo " on %F{blue}$branch%f$git_state"
        fi
      }
      
      # Simple prompt (will be overridden by custom prompt if available)
      PROMPT='%F{green}%~%f$(git_prompt_info)
%F{cyan}❯%f '
      
      # Right prompt with execution time
      RPROMPT=""
      
      # FZF configuration
      export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --info=inline"
      export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git"
      export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
      
      # Quick directory jumping
      c() {
        local dir
        dir=$(fd --type d --hidden --follow --exclude .git . ''${1:-$CODE_DIR} | fzf +m) && cd "$dir"
      }
      
      # fzf-powered command history search
      fh() {
        eval $(history | fzf +s --tac | sed 's/ *[0-9]* *//')
      }
      
      # Initialize mise (if installed)
      if command -v mise &>/dev/null; then
        eval "$(mise activate zsh)"
      fi
      
      # Source local configuration if it exists
      [[ -f ~/.localrc ]] && source ~/.localrc
      
      # Better CD - track directory history
      setopt AUTO_CD
      setopt AUTO_PUSHD
      setopt PUSHD_IGNORE_DUPS
      setopt PUSHD_SILENT
      
      # Don't beep
      setopt NO_BEEP
      
      # Completion settings
      setopt COMPLETE_IN_WORD
      setopt ALWAYS_TO_END
      setopt PATH_DIRS
      setopt AUTO_MENU
      setopt AUTO_LIST
      setopt AUTO_PARAM_SLASH
      setopt MENU_COMPLETE
      
      # History settings
      setopt EXTENDED_HISTORY
      setopt HIST_VERIFY
      setopt HIST_REDUCE_BLANKS
      
      # Glob settings
      setopt EXTENDED_GLOB
      
      # Correction
      setopt CORRECT
      setopt CORRECT_ALL
      
      # Jobs
      setopt LONG_LIST_JOBS
      setopt AUTO_RESUME
      setopt NOTIFY
      setopt NO_BG_NICE
      setopt NO_HUP
      setopt NO_CHECK_JOBS
      
      # Enable colors
      autoload -U colors && colors
      
      # Better completion
      zstyle ':completion:*' menu select
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
      zstyle ':completion:*' list-colors "''${(@s.:.)LS_COLORS}"
      zstyle ':completion:*:*:*:*:*' menu select
      zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
      zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
      
      # Partial completion suggestions
      zstyle ':completion:*' list-suffixes
      zstyle ':completion:*' expand prefix suffix
    '';
    
    plugins = [
      {
        name = "fzf-tab";
        src = pkgs.fetchFromGitHub {
          owner = "Aloxaf";
          repo = "fzf-tab";
          rev = "c2b4aa5ad2532cca91f23908ac7f00efb7ff09c9";
          sha256 = "sha256-gvZp8P3quOtcy1Xtt1LAW1cfZ/zCtnAmnWqcwrKel6w=";
        };
      }
    ];
  };
  
  # ZSH-specific files to link
  home.file = {
    ".config/zsh/.zshrc".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/nix-setup/config/zsh/.zshrc";
    ".config/zsh/.zsh_prompt".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/nix-setup/config/zsh/.zsh_prompt";
    ".config/zsh/.zsh_functions".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/nix-setup/config/zsh/.zsh_functions";
    ".config/zsh/.zsh_aliases".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/nix-setup/config/zsh/.zsh_aliases";
  };
}
