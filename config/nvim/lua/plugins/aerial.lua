local M = {
    name = 'aerial',
    plug = {
        'https://github.com/stevearc/aerial.nvim',
    },
    depends = {
        'https://github.com/nvim-treesitter/nvim-treesitter',
        'https://github.com/nvim-tree/nvim-web-devicons',
    },
    priority = 90,
}

M.post_setup = function()
    vim.keymap.set('n', '{', '<cmd>AerialPrev<CR>')
    vim.keymap.set('n', '}', '<cmd>AerialNext<CR>')
    vim.keymap.set('n', '<leader>A', '<cmd>AerialToggle! right<CR>',
                   { desc = 'Toggle Aerial' })
end

return M
