{ config, pkgs, user, ... }:

{
  imports = [
    ./modules/home/dotfiles.nix
    ./modules/home/theming.nix
    ./modules/home/programs.nix
    ./modules/home/packages-core.nix
    ./modules/home/packages-apps.nix
    ./modules/home/directories.nix
  ];

  home.username = user.username;
  home.homeDirectory = "/home/${user.username}";
  home.stateVersion = "26.05";
}
