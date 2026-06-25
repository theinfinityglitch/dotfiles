return {
  'MeanderingProgrammer/render-markdown.nvim',
  ft = { 'markdown' }, -- Lazy load on markdown files
  dependencies = {
    'romus204/tree-sitter-manager.nvim',
    'nvim-tree/nvim-web-devicons', -- Optional, for icons
  },
  opts = {
    -- Core plugin options go here
  },
  config = function(_, opts)
    require('render-markdown').setup(opts)

    -- CRITICAL STEP: Auto-enable the native Neovim Treesitter highlighter
    -- for markdown buffers so render-markdown can hook into the syntax tree.
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'markdown',
      callback = function(args)
        vim.treesitter.start(args.buf, 'markdown')
      end,
    })
  end,
}
