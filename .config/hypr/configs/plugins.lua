------------------
---- PLUGINS -----
------------------

-- Hyprbars

-- if hl.plugin.hyprbars ~= nil then
--     hl.config({
--         plugin = {
--             hyprbars = {
--                 bar_height = 30,
--                 bar_part_of_window = true,
--                 bar_color = "rgb(D2C4A0)",
--                 bar_text_align = "left",
--                 bar_precedence_over_border = true,
--                 on_double_click = "hyprctl dispatch 'hl.dsp.window.float({ action = 'toggle' })'",
--                 col = {
--                     text = "rgb(282828)",
--                 }
--             }
--         }
--     })
-- end

-- Disable hyprbars for all windows by default

-- hl.window_rule({
--     match = { float = false },
--     name = "hyprbars_no_bar_tiled",
--     ["hyprbars:no_bar"] = true,
-- })

-- hl.window_rule({
--     name = "disable-hyprbars",
--     match = { float = 0 },

--     -- hyprbars_no_bar = true
--     -- plugin = {
--     --     hyprbars = {
--     --         no_bar = true
--     --     }
--     -- }
--     -- hyprbars.no_bar = true
-- })

-- hl.dsp.window.set_prop({ prop = "plugins.hyprbars.no_bar", value = "true" })

-- Enable hyprbars only for floating windows

-- hl.windowrule({
--     name = "enable-hyprbars",
--     match.float = 1,
--     hyprbars.no_bar = false,
-- })

-- Set hyprbar color for inactive windows

-- hl.windowrule({
--     name = "hyprbar-inactive-hyprbars",
--     match:focus = false,
--     hyprbars.bar_color = "rgb(504945)",
--     hyprbars.title_color = "rgb(A89984)",
-- })
