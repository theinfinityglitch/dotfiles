{ config, ... }:
let
  dotfiles = "${config.home.homeDirectory}/dotfiles/.config";
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
  configs = {
    hypr = "hypr";
    nvim = "nvim";
    quickshell = "quickshell";
    kitty = "kitty";
    vicinae = "vicinae";
    fastfetch = "fastfetch";
    qt6ct = "qt6ct";
    qt5ct = "qt5ct";
    wlogout = "wlogout";
    kdeglobals = "kdeglobals";
  };
in
{
  xdg.configFile = builtins.mapAttrs (name: subpath: {
    source = create_symlink "${dotfiles}/${subpath}";
    recursive = true;
  }) configs;
}
