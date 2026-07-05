local programs = require('configs.programs')

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- size = { 1472, 868 },

for program, flags in pairs(programs.window_settings) do
  if program ~= nil and flags ~= nil then
    for _, flag in pairs(flags) do
      if flag == 'B' then
        hl.window_rule({
          name = 'apply-' .. program .. '-rules',
          match = { class = '^(' .. program .. ')$' },
          opacity = '0.90 0.90',
        })
      end
      if flag == 'F' then
        hl.window_rule({
          name = 'apply-' .. program .. '-rules',
          match = { class = '^(' .. program .. ')$' },
          float = true,
          center = true,
          size = { 1280, 720 },
        })
      end
    end
  end
end

-- Ignore maximize requests from all apps. You'll probably like this.
hl.window_rule({
  name = 'suppress-maximize-events',
  match = { class = '.*' },

  suppress_event = 'maximize',
})

hl.window_rule({
  -- Fix some dragging issues with XWayland
  name = 'fix-xwayland-drags',
  match = {
    class = '^$',
    title = '^$',
    xwayland = true,
    float = true,
    fullscreen = false,
    pin = false,
  },

  no_focus = true,
})

hl.layer_rule({
  name = 'menu-blur',
  match = { namespace = 'quickshell:slim_bar' },
  blur = true,
  no_anim = true,
})
