---------------------
---- MY PROGRAMS ----
---------------------

local programs = {}

programs.terminal = 'kitty'
programs.fileManager = 'nautilus'
programs.menu = 'vicinae'
programs.colorPicker = 'hyprpicker'
programs.browser = 'firefox'
programs.calculator = 'kcalc'

-- F -> Float
-- B -> Blur back

programs.window_settings = {
  ['org.pulseaudio.pavucontrol'] = { 'F' },
  ['org.gnome.Nautilus'] = { 'F' },
  ['org.kde.dolphin'] = { 'F' },
  ['code'] = { 'F' },
  ['dev.zed.Zed'] = { 'B', 'F' },
  ['kitty'] = { 'B', 'F' },
  ['Alacritty'] = { 'B', 'F' },
  ['foot'] = { 'B', 'F' },
  ['com.mitchellh.ghostty'] = { 'B', 'F' },
  ['org.freedesktop.impl.portal.desktop.kde'] = { 'F' },
  ['org.godotengine.ProjectManager'] = { 'F' },
  ['spotify'] = { 'B', 'F' },
  ['Launcher'] = { 'F' }, -- Seed Laucher: Launcher for Flax Engine
}

return programs
