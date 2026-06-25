local programs = require('configs.programs')

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

for _, value in pairs(programs.blur_back) do
  hl.window_rule({
    name = 'apply-' .. value .. '-blur',
    match = { class = '^(' .. value .. ')$' },
    opacity = '0.90 0.90',
  })
end

for _, value in pairs(programs.start_floating) do
  hl.window_rule({
    name = 'apply-' .. value .. '-floating',
    match = { class = '^(' .. value .. ')$' },
    float = true,
    size = { 1280, 720 },
  })
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
