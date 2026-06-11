return {
  'theinfinityglitch/lualine.nvim',
  dev = true,
  dependencies = { 'nvim-tree/nvim-web-devicons' },

  config = function()
    require('lualine').setup({
      theme = 'gruvbox',
      options = {
        icons_enabled = false,
        component_separators = '',
        section_separators = '',
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diff' },
        lualine_c = { { 'filename', path = 1 } },
        lualine_x = { 'diagnostics' },
        lualine_y = {
          { 'filetype_lsp', show_name = false, lsp_separator = '', lsp_icon = '' },
          --           { 'lsp_status', show_name = false, padding = { left = 0, right = 1 } },
        },
        lualine_z = { 'location' },
      },
      tabline = {
        lualine_a = { 'buffers' },
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = { 'tabs' },
      },
    })
  end,
}
