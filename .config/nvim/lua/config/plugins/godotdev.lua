return {
  {
    'Mathijs-Bakker/godotdev.nvim',

    config = function()
      require('godotdev').setup({
        treesitter = {
          auto_setup = false,
        },
      })
    end,
  },
  {
    'Cretezy/godot-server.nvim',
  },
}
