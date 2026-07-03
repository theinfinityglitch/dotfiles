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
        python = { 'isort', 'black' },
        xml = { 'xmlstarlet_format' },
        cpp = { 'clang-format' },
        qml = { 'qmlformat' },
      },
      formatters = {
        prettier = {
          prepend_args = { '--trailing-comma', 'none' },
        },
        formatters = {
          ['clang-format'] = {
            -- Pass specific fallback styles directly through CLI arguments
            prepend_args = { "--style='{BasedOnStyle: Google, IndentWidth: 4}'" },
          },
        },
        xmlstarlet_format = {
          command = 'xmlstarlet',
          args = { 'fo', '--net', '-o', '-s', '2', '-' },
          stdin = true,
          ignore_stderr = true,
          exit_codes = { 0, 1, 3, 210, 224 },
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
