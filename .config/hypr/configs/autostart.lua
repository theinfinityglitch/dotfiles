-------------------
---- AUTOSTART ----
-------------------

hl.on('hyprland.start', function()
  hl.exec_cmd('gnome-keyring-daemon --start --components=secrets')
  hl.exec_cmd('/usr/lib/hyprpolkitagent/hyprpolkitagent')
  hl.exec_cmd('dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP')
  hl.exec_cmd(
    'sleep 1 && killall -e xdg-desktop-portal-hyprland && killall -e xdg-desktop-portal-wlr && killall xdg-desktop-portal && /usr/lib/xdg-desktop-portal-hyprland & sleep 2 && /usr/lib/xdg-desktop-portal &'
  )
  hl.exec_cmd('gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"')
  hl.exec_cmd('gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"')
  hl.exec_cmd('gsettings set org.gnome.desktop.wm.preferences button-layout :')
  hl.exec_cmd('awww-daemon')
  hl.exec_cmd('vicinae server --open')
  hl.exec_cmd('quickshell')
  hl.exec_cmd('source ~/.config/hypr/scripts/random_wall.sh')
  hl.exec_cmd('hypridle')
  hl.exec_cmd('hyprpm reload -n')
  hl.exec_cmd('kbuildsycoca6 --noincremental')
end)
