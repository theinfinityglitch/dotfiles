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
        json = { 'prettier', 'jq', stop_after_first = true },
        jsonc = { 'prettier', 'jq', stop_after_first = true },
        zig = { 'zigfmt' },
        cs = { 'csharpier' },
      },
      formatters = {
        prettier = {
          prepend_args = { '--trailing-comma', 'none' },
        },
      },
      default_format_opts = {
        lsp_format = 'fallback',
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
