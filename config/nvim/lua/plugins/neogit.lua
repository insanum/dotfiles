return {
    'NeogitOrg/neogit',
    enabled = true,
    dependencies = {
        'nvim-lua/plenary.nvim',
        'sindrets/diffview.nvim',
        'nvim-tree/nvim-web-devicons',
        --'nvim-telescope/telescope.nvim',
        'echasnovski/mini.pick',
    },
    config = true,
    keys = {
        { '<leader>hg', '<cmd>Neogit<CR>', desc = 'git Neogit' },
    },
}
