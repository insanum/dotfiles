return {
    'NeogitOrg/neogit',
    enabled = true,
    dependencies = {
        'nvim-lua/plenary.nvim',
        'sindrets/diffview.nvim',
    },
    config = true,
    keys = {
        { '<leader>hg', '<cmd>Neogit<CR>', desc = 'Neogit' },
    },
}
