{ config, pkgs, user, ... }:

{
  imports = [
    /etc/nixos/hardware-configuration.nix
    ./modules/nixos/boot.nix
    ./modules/nixos/hardware.nix
    ./modules/nixos/locale.nix
    ./modules/nixos/desktop.nix
    ./modules/nixos/security.nix
    ./modules/nixos/gaming.nix
  ];

  networking.hostName = user.hostName;
  networking.networkmanager.enable = true;

  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "26.05";
}
