{ pkgs, user, ... }:
{
  security.polkit.enable = true;

  programs.nix-ld.enable = true;

  users.users.${user.username} = {
    isNormalUser = true;
    description = user.fullName;
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
