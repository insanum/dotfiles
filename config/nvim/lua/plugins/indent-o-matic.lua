local M = {
    name = 'indent-o-matic',
    plug = {
        'https://github.com/Darazaki/indent-o-matic',
    },
    priority = 10,
}

M.opts = {
    max_lines = 2048,
    standard_widths = { 4, 8 },
    skip_multiline = true,
}

return M
