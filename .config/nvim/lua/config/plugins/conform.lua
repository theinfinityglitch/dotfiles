return {
  'stevearc/conform.nvim',

  config = function()
    require('conform').setup({
      formatters_by_ft = {
        lua = { 'stylua', stop_after_first = true },
        javascript = { 'prettier', stop_after_first = true },
        typescript = { 'prettier', stop_after_first = true },
        javascriptreact = { 'prettier', stop_after_first = true },
        typescriptreact = { 'prettier', stop_after_first = true },
        css = { 'prettier', stop_after_first = true },
        json = { 'prettierd', 'prettier', 'jq', stop_after_first = true },
        jsonc = { 'prettierd', 'prettier', 'jq', stop_after_first = true },
        zig = { 'zigfmt' },
      },
      formatters = {
        prettier = {
          prepend_args = { '--trailing-comma', 'none' },
        },
        prettierd = {
          prepend_args = { '--trailing-comma', 'none' },
        },
      },
    })

    vim.api.nvim_create_autocmd('BufWritePre', {
      pattern = '*',
      callback = function(args)
        require('conform').format({ bufnr = args.buf })
      end,
    })
  end,
}
