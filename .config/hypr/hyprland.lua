require("configs.monitors")
require("configs.autostart")
require("configs.env")
require("configs.permissions")
require("configs.plugins")
require("configs.look")
require("configs.layouts")
require("configs.misc")
require("configs.binds")
require("configs.input")
require("configs.rules")

hl.exec_cmd(
    "bash -c 'gdbus wait --session --activate --timeout 10 org.freedesktop.Notifications && notify-send \"Configuration loaded successfully!\" --app-name \"Hyprland\" --icon \"/home/themaster/.config/hypr/favicon.svg\"'")
