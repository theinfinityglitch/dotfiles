{
  description = "NixOS multi-user dotfiles";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vicinae.url = "github:vicinaehq/vicinae";
  };

  outputs = { self, nixpkgs, home-manager, vicinae, ... }:
    let
      mkSystem = userFile:
        let
          user = import userFile;
        in
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit user; };
          modules = [
            ./configuration.nix
            vicinae.nixosModules.default
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = { inherit user; };
                users.${user.username} = import ./home.nix;
                backupFileExtension = "backup";
              };
            }
          ];
        };
    in
    {
      nixosConfigurations."nixos-themaster" = mkSystem ./users/themaster.nix;
    };
}
