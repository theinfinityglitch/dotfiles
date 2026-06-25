---------------------
---- MY PROGRAMS ----
---------------------

local programs = {}

programs.terminal = 'kitty'
programs.fileManager = 'dolphin'
programs.menu = 'vicinae'
programs.colorPicker = 'hyprpicker'
programs.browser = 'firefox'
programs.calculator = 'kcalc'
programs.start_floating = {
  'org.pulseaudio.pavucontrol',
  'org.gnome.Nautilus',
  'org.kde.dolphin',
  'code',
  'dev.zed.Zed',
  'kitty',
  'Alacritty',
  'foot',
  'com.mitchellh.ghostty',
  'org.freedesktop.impl.portal.desktop.kde',
}
programs.blur_back = {
  'kitty',
  'Alacritty',
  'foot',
  'dev.zed.Zed',
  'com.mitchellh.ghostty',
}

return programs
