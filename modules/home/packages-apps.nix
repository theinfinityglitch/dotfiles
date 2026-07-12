{ pkgs, ... }:
{
  home.packages = with pkgs; [
    vesktop
    spotify
    steam-run
    vscode
    zed-editor
    blender
  ];
}
