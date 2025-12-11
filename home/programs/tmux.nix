{ config, pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    
    # Use a different prefix key
    prefix = "C-a";
    
    # Start windows and panes at 1, not 0
    baseIndex = 1;
    
    # Enable mouse support
    mouse = true;
    
    # Increase history limit
    historyLimit = 50000;
    
    # Enable 24-bit color support
    terminal = "tmux-256color";
    
    # Don't rename windows automatically
    disableConfirmationPrompt = true;
    
    # Enable vi mode
    keyMode = "vi";
    
    # Faster escape time for neovim
    escapeTime = 0;
    
    # Enable focus events for better vim integration
    extraConfig = ''
      # Better colors
      set-option -sa terminal-overrides ",xterm*:Tc"
      set-option -sa terminal-overrides ',*:Smulx=\E[4::%p1%dm'
      set-option -sa terminal-overrides ',*:Setulc=\E[58::2::%p1%{65536}%/%d::%p1%{256}%/%{255}%&%d::%p1%{255}%&%d%;m'
      
      # Enable focus events
      set-option -g focus-events on
      
      # Use true colors
      set -g default-terminal "tmux-256color"
      set -ag terminal-overrides ",xterm-256color:RGB"
      
      # Start window and pane numbering at 1
      set -g pane-base-index 1
      set-window-option -g pane-base-index 1
      
      # Renumber windows when one is closed
      set -g renumber-windows on
      
      # Use vim keybindings in copy mode
      setw -g mode-keys vi
      
      # Setup 'v' to begin selection as in Vim
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "pbcopy"
      bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "pbcopy"
      
      # Update default binding of 'Enter' to also use copy-pipe
      unbind -T copy-mode-vi Enter
      bind-key -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel "pbcopy"
      
      # Vim-like pane switching
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R
      
      # Vim-like pane resizing
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5
      
      # Better splitting
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      unbind '"'
      unbind %
      
      # New windows in current path
      bind c new-window -c "#{pane_current_path}"
      
      # Easy config reload
      bind r source-file ~/.config/tmux/tmux.conf \; display-message "Config reloaded"
      
      # Status bar configuration
      set -g status-position top
      set -g status-justify left
      set -g status-style 'bg=default fg=white'
      
      set -g status-left-length 40
      set -g status-left '#[fg=blue,bold]#S #[fg=white]» '
      
      set -g status-right-length 100
      set -g status-right '#[fg=white]%a %h %d %H:%M '
      
      setw -g window-status-current-style 'fg=black bg=blue bold'
      setw -g window-status-current-format ' #I:#W#F '
      
      setw -g window-status-style 'fg=white'
      setw -g window-status-format ' #I:#W#F '
      
      # Pane borders
      set -g pane-border-style 'fg=brightblack'
      set -g pane-active-border-style 'fg=blue'
      
      # Message style
      set -g message-style 'fg=black bg=yellow bold'
      
      # Clock mode
      setw -g clock-mode-colour blue
      
      # Activity monitoring
      setw -g monitor-activity on
      set -g visual-activity off
      
      # Source additional tmux configuration from dotfiles
      source-file ~/.config/nix-setup/config/tmux/tmux.conf
    '';
    
    plugins = with pkgs.tmuxPlugins; [
      sensible
      yank
      {
        plugin = resurrect;
        extraConfig = ''
          set -g @resurrect-strategy-nvim 'session'
          set -g @resurrect-capture-pane-contents 'on'
        '';
      }
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '15'
        '';
      }
    ];
  };
  
  # Link tmux config from dotfiles
  home.file.".config/tmux/tmux.conf".source = 
    config.lib.file.mkOutOfStoreSymlink 
      "${config.home.homeDirectory}/.config/nix-setup/config/tmux/tmux.conf";
}
