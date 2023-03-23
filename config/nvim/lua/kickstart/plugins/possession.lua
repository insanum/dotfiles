return {
  'https://github.com/jedrzejboczar/possession.nvim',
  config = function()
    require('possession').setup {
      commands = {
        save = 'Psave',
        load = 'Pload',
        close = 'Pclose',
        delete = 'Pdelete',
        show = 'Pshow',
        list = 'Plist',
        migrate = 'Pmigrate',
      },
    }
    require('telescope').load_extension('possession')
  end,
}
