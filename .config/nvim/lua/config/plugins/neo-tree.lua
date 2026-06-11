return {
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      'nvim-tree/nvim-web-devicons',
    },
    opts = {
      filesystem = {
        -- bind_to_cwd = false,
        follow_current_file = {
          enabled = true,
          leave_dirs_open = false,
        },
        filtered_items = {
          hide_dotfiles = false, -- Disable hiding of dotfiles
          hide_gitignored = false, -- Optional: Disable hiding of gitignored files
        },
      },
      sources = {
        'filesystem',
        'buffers',
        'git_status',
        'dotnet',
      },
    },
    keys = {
      -- Toggle Neo-tree with CTRL + b
      { '<C-b>', '<cmd>Neotree toggle source=last<cr>', desc = 'Neo-tree' },
    },
  },
  {
    'Crysthamus/nvim-file-operations',
    -- branch = "compat" -- if you are on Neovim <= 0.10
    dependencies = {
      'nvim-neo-tree/neo-tree.nvim', -- makes sure that this loads after Neo-tree.
    },
    config = function()
      require('nvim-file-operations').setup()
    end,
  },
  {
    's1n7ax/nvim-window-picker',
    version = '2.*',
    config = function()
      require('window-picker').setup({
        filter_rules = {
          include_current_win = false,
          autoselect_one = true,
          -- filter using buffer options
          bo = {
            -- if the file type is one of following, the window will be ignored
            filetype = { 'neo-tree', 'neo-tree-popup', 'notify' },
            -- if the buffer type is one of following, the window will be ignored
            buftype = { 'terminal', 'quickfix' },
          },
        },
      })
    end,
  },
}
