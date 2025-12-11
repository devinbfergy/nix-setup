{
  description = "NixOS configuration for WSL";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    nix-setup = {
      url = "path:/home/nixos/.config/nix-setup";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, nixos-wsl, home-manager, nix-setup, ... }@inputs: {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          nixos-wsl.nixosModules.wsl
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.nixos = import "${nix-setup}/home";
          }
        ];
      };
    };
  };
}
