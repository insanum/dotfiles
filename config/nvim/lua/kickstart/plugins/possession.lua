return {
  'https://github.com/jedrzejboczar/possession.nvim',
  config = function()
    require('possession').setup {
      commands = {
        save = 'PoSave',
        load = 'PoLoad',
        close = 'PoClose',
        delete = 'PoDelete',
        show = 'PoShow',
        list = 'PoList',
        migrate = 'PoMigrate',
      },
    }
    require('telescope').load_extension('possession')
  end,
}
