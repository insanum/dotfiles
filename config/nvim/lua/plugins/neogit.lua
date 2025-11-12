local M = {}

M.setup = function(add)
    add({
        source = 'NeogitOrg/neogit',
        depends = {
            'nvim-lua/plenary.nvim',
            'sindrets/diffview.nvim',
        },
    })

    require('neogit').setup()

    vim.keymap.set('n', '<leader>hg', '<cmd>Neogit<CR>',
                   { desc = 'Neogit', })
end

return M
