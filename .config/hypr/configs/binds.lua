---------------------
---- KEYBINDINGS ----
---------------------

local programs = require("configs.programs")
local config_cmd = programs.terminal .. " -d ~/dotfiles nvim"
local mainMod = "SUPER" -- Sets "Windows" key as main modifier

-- Fast launch apps

hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(programs.terminal, { float = true, size = { 1280, 720 } }))
hl.bind(mainMod .. " + SUPER_L", hl.dsp.exec_cmd(programs.menu .. " toggle"), { release = true })
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(programs.fileManager, { float = true, size = { 1280, 720 } }))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(programs.browser))
hl.bind(mainMod .. " + code:31", hl.dsp.exec_cmd(config_cmd, { float = true, size = { 1280, 720 } }))
hl.bind("code:148", hl.dsp.exec_cmd(programs.calculator, { float = true, size = { 1280, 720 } }))

-- Restart components

hl.bind("CTRL + Escape", hl.dsp.exec_cmd("killall waybar || waybar"))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("hyprctl reload"))

-- Utilities

hl.bind(mainMod .. " + P", hl.dsp.exec_cmd(programs.colorPicker .. " | wl-copy"))
hl.bind(
	mainMod .. " + N",
	hl.dsp.exec_cmd(programs.menu .. " vicinae://launch/@theinfinityglitch/notification-center/notifications")
)
hl.bind(mainMod .. " + COMMA", hl.dsp.exec_cmd(programs.menu .. " vicinae://launch/core/search-emojis"))

-- Clipboard

hl.bind(mainMod .. " + C", hl.dsp.exec_cmd(programs.menu .. " vicinae://launch/clipboard/history"))

-- Wallpaper changes

hl.bind(mainMod .. " + O", hl.dsp.exec_cmd("~/.config/hypr/scripts/random_wall.sh"))
hl.bind(
	mainMod .. " + M",
	hl.dsp.exec_cmd(programs.menu .. " vicinae://launch/@theinfinityglitch/wallpapers/wallpaper-selector")
)

-- Screenshots

hl.bind("Print", hl.dsp.exec_cmd("grimblast --freeze --notify copysave screen"))
hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd("grimblast --freeze --notify copysave active"))
hl.bind(mainMod .. " + ALT + Print", hl.dsp.exec_cmd("grimblast --freeze --notify copysave area"))

-- Lock/logout selector

hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("~/.config/hypr/scripts/random_wall_lock.sh && hyprlock"))
hl.bind(mainMod .. " + ESCAPE", hl.dsp.exec_cmd("pidof wlogout || wlogout"))
hl.bind(
	mainMod .. " + ALT + M",
	hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'")
)

-- Window actions

hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + W", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + D", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit")) -- dwindle only

-- Move focus with mainMod + arrow keys

hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

-- Move windows on the current workspace

hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.move({ direction = "down" }))

-- Switch between windows in a floating workspace

hl.bind("SUPER + Tab", function()
	hl.dispatch(hl.dsp.window.cycle_next()) -- Change focus to another window
	hl.dispatch(hl.dsp.window.bring_to_top()) -- Bring it to the top
end)

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]

for i = 1, 10 do
	local key = i % 10 -- 10 maps to key 0
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Example special workspace (scratchpad)

hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness

hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { locked = true, repeating = true })

-- Requires playerctl

hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
