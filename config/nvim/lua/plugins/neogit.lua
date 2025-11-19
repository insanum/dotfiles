local M = {
    name = 'neogit',
    plug = {
        'https://github.com/NeogitOrg/neogit',
    },
    depends = {
        'https://github.com/nvim-lua/plenary.nvim',
        'https://github.com/sindrets/diffview.nvim',
    },
    priority = 90,
}

M.post_setup = function()
    vim.keymap.set('n', '<leader>hg', '<cmd>Neogit<CR>',
                   { desc = 'Neogit', })
end

return M
