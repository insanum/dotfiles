return {
  'https://github.com/alvarosevilla95/luatab.nvim',
  dependencies = {
    'kyazdani42/nvim-web-devicons',
  },
  config = function()
    require('luatab').setup { }
  end,
}
