return {
  'https://github.com/tom-anders/telescope-vim-bookmarks.nvim',
  config = function()
    require('telescope').load_extension('vim_bookmarks')
  end,
}
