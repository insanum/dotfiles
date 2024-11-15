return {
    'debugloop/telescope-undo.nvim',
    dependencies = { -- note how they're inverted to above example
        {
            'nvim-telescope/telescope.nvim',
            dependencies = {
                'nvim-lua/plenary.nvim'
            },
        },
    },
    keys = {
        {
            '<leader>u',
            '<cmd>Telescope undo<CR>',
            desc = 'undo history',
        },
    },
    opts = {
        extensions = {
            undo = {
                use_delta = false,
            },
        },
    },
    config = function(_, opts)
        require('telescope').setup(opts)
        require('telescope').load_extension('undo')
    end,
}
