return {
    'NeogitOrg/neogit',
    dependencies = {
        'nvim-lua/plenary.nvim',
        'sindrets/diffview.nvim',
        'nvim-telescope/telescope.nvim',
    },
    config = true,
    keys = {
        { '<leader>hg', '<cmd>Neogit<CR>', desc = 'git Neogit' },
    },
}
