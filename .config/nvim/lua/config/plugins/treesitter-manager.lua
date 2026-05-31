return {
    'romus204/tree-sitter-manager.nvim',
    dependencies = {},
    lazy = false,

    config = function()
        require('tree-sitter-manager').setup({
            ensure_installed = {
                --   'javascript',
                --   'typescript',
                --   'tsx',
                'json',
                --   'jsdoc',
                --   'html',
                --   'css',
                --   'regex',
                'python',
                'lua',
                'vim',
                'vimdoc',
                'c',
                'cpp',
                'c_sharp',
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
