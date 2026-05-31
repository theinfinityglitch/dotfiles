--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

hl.window_rule({
    name = "apply-terminal-opacity",
    match = { class = "^(kitty)$" },
    opacity = "0.90 0.90"
})

hl.window_rule({
    name = "disable-rider-opacity",
    match = { class = "^(jetbrains-rider)$" },
    opacity = "1.0"
})

-- Ignore maximize requests from all apps. You'll probably like this.

hl.window_rule({
    name           = "suppress-maximize-events",
    match          = { class = ".*" },

    suppress_event = "maximize",
})

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name     = "fix-xwayland-drags",
    match    = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})
