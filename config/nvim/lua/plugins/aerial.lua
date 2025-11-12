local M = {}

M.setup = function(add)
    add({
        source = 'stevearc/aerial.nvim',
        depends = {
            'nvim-treesitter/nvim-treesitter',
            'nvim-tree/nvim-web-devicons',
        },
    })

    require('aerial').setup()

    vim.keymap.set('n', '{', '<cmd>AerialPrev<CR>')
    vim.keymap.set('n', '}', '<cmd>AerialNext<CR>')
    vim.keymap.set('n', '<leader>A', '<cmd>AerialToggle! right<CR>',
                   { desc = 'Toggle Aerial' })
end

return M
