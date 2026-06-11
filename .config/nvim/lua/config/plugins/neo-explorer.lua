return {
  'themaster/neo-explorer.nvim',
  -- dependencies = { 'a-usr/xml2lua.nvim' },
  dev = true,
  -- name = 'neo-explorer.nvim',
  config = function()
    require('neo-explorer').setup({
      auto_load_solution = true,
    })
  end,
}
