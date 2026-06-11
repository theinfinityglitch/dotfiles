return {

  'vhyrro/luarocks.nvim',
  priority = 1000, -- Load this before other plugins
  config = true,
  opts = {
    rocks = { 'xml2lua' },
  },
}
