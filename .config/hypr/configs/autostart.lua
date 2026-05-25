-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
    hl.exec_cmd("/usr/lib/hyprpolkitagent/hyprpolkitagent")
    hl.exec_cmd("dbus-update-activation-environment --systemd --all")
    hl.exec_cmd("systemctl --user start rnd")
    -- hl.exec_cmd("rnd")
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("vicinae server --open")
    hl.exec_cmd("waybar")
    hl.exec_cmd("source ~/.config/hypr/scripts/random_wall.sh")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("hyprpm reload -n")
    hl.exec_cmd("kbuildsycoca6 --noincremental")
end)
