local M = {
    name = 'snacks',
    plug = {
        'https://github.com/folke/snacks.nvim',
    },
    priority = 90,
}

M.opts = {
    image = {
        enabled = true,
        doc = {
            inline = true,
        },
    },
}

return M
