return {
    'jedrzejboczar/possession.nvim',
    opts = {
        commands = {
            save = 'PoSave',
            load = 'PoLoad',
            close = 'PoClose',
            delete = 'PoDelete',
            show = 'PoShow',
            list = 'PoList',
            migrate = 'PoMigrate',
        },
    },
    keys = {
        { ',o', '<cmd>Telescope possession list<CR>', desc = 'Possession' },
    },
    config = function(_, opts)
        require('possession').setup(opts)
        require('telescope').load_extension('possession')
    end,
}
