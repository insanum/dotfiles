return {
  'https://github.com/akinsho/bufferline.nvim',
  version = 'v3.*',
  dependencies = {
    'nvim-tree/nvim-web-devicons',
  },
  config = function()
    require('bufferline').setup {
      options = {
        mode = 'tabs',
        numbers = 'ordinal',
        show_close_icon = false,
        show_tab_indicators = true,
        --indicator = { style = 'underline' },
      }
    }
  end,
}
