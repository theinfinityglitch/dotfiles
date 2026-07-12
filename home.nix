{ config, pkgs, ... }:

{
  imports = [
    ./modules/home/dotfiles.nix
    ./modules/home/theming.nix
    ./modules/home/programs.nix
    ./modules/home/packages.nix
    ./modules/home/directories.nix
  ];

  home.username = "themaster";
  home.homeDirectory = "/home/themaster";
  home.stateVersion = "26.05";
}
