{
  description = "NixOS first try";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vicinae.url = "github:vicinaehq/vicinae";
  };

  outputs = { self, nixpkgs, home-manager, vicinae, ... }: {
    nixosConfigurations.nixos-themaster = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        vicinae.nixosModules.default
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.themaster = import ./home.nix;
            backupFileExtension = "backup";
          };
        }
      ];
    };
  };
}
