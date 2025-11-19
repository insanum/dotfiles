local M = {
    name = 'toggleterm',
    plug = {
        'https://github.com/akinsho/toggleterm.nvim',
    },
    priority = 90,
}

M.opts = {
    shade_terminals = false,
}

return M
