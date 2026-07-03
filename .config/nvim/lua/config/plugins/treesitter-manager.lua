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
        'markdown',
        'markdown_inline',
        'html',
        'latex',
        'yaml',
        'rust',
      },
      -- highlight = true,
    })
  end,
}
