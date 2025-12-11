{
  description = "Cross-platform Nix configuration for macOS and Linux";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, ... }@inputs: 
    let
      # Helper function to generate system configs
      mkSystem = { system, hostname, username, isDarwin ? false }:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        in
        if isDarwin then
          nix-darwin.lib.darwinSystem {
            inherit system;
            specialArgs = { inherit inputs username hostname; };
            modules = [
              ./darwin
              home-manager.darwinModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.${username} = import ./home;
                home-manager.extraSpecialArgs = { inherit username; };
              }
            ];
          }
        else
          home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            extraSpecialArgs = { inherit username hostname; };
            modules = [ ./home ];
          };
    in
    {
      # macOS configurations
      darwinConfigurations = {
        # Default macOS configuration
        # Usage: darwin-rebuild switch --flake .#macbook
        macbook = mkSystem {
          system = "aarch64-darwin";  # Apple Silicon
          hostname = "macbook";
          username = "devin";  # Change this to your username
          isDarwin = true;
        };
        
        # Intel Mac configuration
        # Usage: darwin-rebuild switch --flake .#macbook-intel
        macbook-intel = mkSystem {
          system = "x86_64-darwin";
          hostname = "macbook-intel";
          username = "devin";
          isDarwin = true;
        };
      };

      # Standalone home-manager configurations (for Linux or macOS without nix-darwin)
      homeConfigurations = {
        # Linux configuration
        # Usage: home-manager switch --flake .#linux
        linux = mkSystem {
          system = "x86_64-linux";
          hostname = "linux-machine";
          username = "devin";
          isDarwin = false;
        };
        
        # ARM Linux configuration
        # Usage: home-manager switch --flake .#linux-arm
        linux-arm = mkSystem {
          system = "aarch64-linux";
          hostname = "linux-arm";
          username = "devin";
          isDarwin = false;
        };
      };

      # Development shells
      # Usage: nix develop
      devShells = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ] (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              nil  # Nix language server
              nixpkgs-fmt  # Nix formatter
            ];
          };
        }
      );
    };
}
