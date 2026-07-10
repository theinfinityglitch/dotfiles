{ pkgs, ... }:
{
  security.polkit.enable = true;

  programs.nix-ld.enable = true;

  users.users."themaster" = {
    isNormalUser = true;
    description = "themaster";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      tree
    ];
    shell = pkgs.fish;
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
      fastfetch
    '';
  };
}
