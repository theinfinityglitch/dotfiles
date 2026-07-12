{ pkgs, ... }:
{
  environment.variables = {
    NIXOS_OZONE_WL = "1";
  };

  services.xserver.xkb = {
    layout = "br";
    variant = "";
  };

  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  services.displayManager.ly.enable = true;

  programs.hyprlock.enable = true;
  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    vim
    hyprland
    playerctl
    kitty
    firefox
    wget
    upower
  ];
}
