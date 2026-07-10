-------------------
---- AUTOSTART ----
-------------------

hl.on('hyprland.start', function()
  hl.exec_cmd('gnome-keyring-daemon --start --components=secrets')
  -- hyprpolkitagent is installed via home.nix and lives in the user's
  -- profile/PATH on NixOS (/nix/store, not /usr/lib like on Arch).
  hl.exec_cmd('hyprpolkitagent')
  hl.exec_cmd('dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP')
  -- NOTE: the manual xdg-desktop-portal kill/relaunch dance from Arch was
  -- removed. On NixOS, `programs.hyprland.enable` in configuration.nix
  -- already sets up and manages the portal via a systemd user service.
  hl.exec_cmd('awww-daemon')
  -- vicinae is NOT started here anymore: it's already autostarted via the
  -- `programs.vicinae.systemd.autoStart = true` home-manager option, so
  -- starting it here too was launching it twice.
  hl.exec_cmd('quickshell')
  hl.exec_cmd('source ~/.config/hypr/scripts/random_wall.sh')
  hl.exec_cmd('hypridle')
  hl.exec_cmd('hyprpm reload -n')
  hl.exec_cmd('kbuildsycoca6 --noincremental')
  hl.exec_cmd('dconf write /org/gnome/desktop/wm/preferences/button-layout \"\'\'\"')
end)
