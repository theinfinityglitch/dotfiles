return {
  'romus204/tree-sitter-manager.nvim',
  dependencies = {},
  lazy = false,

  config = function()
    require('tree-sitter-manager').setup({
      ensure_installed = {
        'json',
        'css',
        'python',
        'lua',
        'vim',
        'vimdoc',
        'c',
        'cpp',
        'c_sharp',
        'zig',
        'gdscript',
      },
    })

    -- vim.api.nvim_create_autocmd('FileType', {
    --   pattern = {
    --     'dart',
    --     'javascript',
    --     'javascriptreact',
    --     'typescript',
    --     'typescriptreact',
    --   },
    --   callback = function()
    --     vim.treesitter.start()
    --   end,
    -- })
  end,
}
