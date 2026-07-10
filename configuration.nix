{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/nixos/boot.nix
    ./modules/nixos/hardware.nix
    ./modules/nixos/locale.nix
    ./modules/nixos/desktop.nix
    ./modules/nixos/security.nix
  ];

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "26.05";
}
