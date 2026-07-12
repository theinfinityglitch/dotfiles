{ pkgs, ... }:
{
  home.packages = with pkgs; [
    quickshell
    awww
    brightnessctl
    fastfetch
    grimblast
    gnome-themes-extra
    adwaita-icon-theme
    wlogout
    hypridle
    hyprpicker
    wl-clipboard
    libnotify
    gnome-keyring
    hyprpolkitagent
    psmisc

    libsForQt5.qt5ct
    kdePackages.qt6ct
    kdePackages.breeze
    kdePackages.ark
    kdePackages.kcalc
    kdePackages.dolphin

    cascadia-code
    nerd-fonts.caskaydia-cove
    nerd-fonts.caskaydia-mono

    neovim
    ripgrep
    nil
    nixpkgs-fmt
    tree-sitter
    nodejs
    gcc
  ];
}
