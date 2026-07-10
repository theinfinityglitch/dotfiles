{ pkgs, ... }:
{
  home.packages = with pkgs; [
    quickshell
    neovim
    ripgrep
    nil
    nixpkgs-fmt
    nodejs
    gcc
    awww
    brightnessctl
    fastfetch
    vesktop
    kdePackages.dolphin
    spotify
    grimblast
    gnome-themes-extra
    adwaita-icon-theme
    wlogout
    hypridle
    steam-run

    libsForQt5.qt5ct
    kdePackages.qt6ct
    kdePackages.breeze
    kdePackages.ark
    kdePackages.kcalc

    cascadia-code
    nerd-fonts.caskaydia-cove
    nerd-fonts.caskaydia-mono

    hyprpicker
    wl-clipboard
    libnotify
    gnome-keyring
    hyprpolkitagent

    tree-sitter
  ];
}
