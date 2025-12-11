{ pkgs, username, hostname, ... }:

{
  # Nix configuration
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "@admin" username ];
      
      # Enable binary cache
      substituters = [
        "https://cache.nixos.org/"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };

    # Auto-optimize nix store
    optimise.automatic = true;

    # Garbage collection
    gc = {
      automatic = true;
      interval.Day = 7;
      options = "--delete-older-than 30d";
    };
  };

  # Enable sudo authentication with Touch ID
  security.pam.enableSudoTouchIdAuth = true;

  # System-wide packages
  environment.systemPackages = with pkgs; [
    vim
    git
  ];

  # Fonts
  fonts = {
    packages = with pkgs; [
      (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })
      monaspace
    ];
  };

  # System configuration
  system = {
    stateVersion = 5;
    
    # Keyboard settings
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };

    defaults = {
      # Dock settings
      dock = {
        autohide = true;
        mru-spaces = false;  # Don't rearrange spaces
        minimize-to-application = true;
        show-recents = false;
        tilesize = 48;
      };

      # Finder settings
      finder = {
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        FXEnableExtensionChangeWarning = false;
        FXPreferredViewStyle = "Nlsv";  # List view
        ShowPathbar = true;
        ShowStatusBar = true;
        _FXShowPosixPathInTitle = true;
      };

      # NSGlobalDomain settings (general macOS settings)
      NSGlobalDomain = {
        AppleInterfaceStyle = "Dark";  # Dark mode
        AppleShowAllExtensions = true;
        AppleShowScrollBars = "Always";
        
        # Keyboard settings
        InitialKeyRepeat = 15;
        KeyRepeat = 2;
        
        # Enable full keyboard access for all controls
        AppleKeyboardUIMode = 3;
        
        # Expand save and print dialogs by default
        NSNavPanelExpandedStateForSaveMode = true;
        NSNavPanelExpandedStateForSaveMode2 = true;
        PMPrintingExpandedStateForPrint = true;
        PMPrintingExpandedStateForPrint2 = true;
        
        # Disable automatic capitalization, period substitution, etc.
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
      };

      # Trackpad settings
      trackpad = {
        Clicking = true;  # Tap to click
        TrackpadThreeFingerDrag = true;
      };

      # Menu bar
      menuExtraClock = {
        Show24Hour = true;
        ShowDate = 1;  # Always
      };

      # Screenshots
      screencapture = {
        location = "~/Pictures/Screenshots";
        type = "png";
      };
    };
  };

  # Homebrew configuration for GUI apps and things not in nixpkgs
  homebrew = {
    enable = true;
    
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";  # Uninstall packages not in config
      upgrade = true;
    };

    taps = [
      "homebrew/bundle"
      "FelixKratz/formulae"
      "nikitabobko/tap"
    ];

    brews = [
      "borders"  # Window borders (macOS-specific)
      "noti"     # Notification utility
      "trash"    # Better rm command for macOS
    ];

    casks = [
      # Terminal emulators
      "ghostty"
      "wezterm"
      
      # Utilities
      "1password-cli"
      "karabiner-elements"
      "aerospace"  # Tiling window manager
    ];

    masApps = {
      # Add Mac App Store apps here if needed
      # Example: "Xcode" = 497799835;
    };
  };

  # Services
  services = {
    nix-daemon.enable = true;
  };

  # Add /run/current-system/sw/bin to PATH for GUI apps
  launchd.user.envVariables.PATH = "/run/current-system/sw/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin";

  # Set hostname
  networking = {
    computerName = hostname;
    hostName = hostname;
    localHostName = hostname;
  };

  # User configuration
  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
  };

  # Auto-upgrade nix-darwin
  system.activationScripts.postUserActivation.text = ''
    # Following line should allow us to avoid a logout/login cycle
    /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
  '';
}
