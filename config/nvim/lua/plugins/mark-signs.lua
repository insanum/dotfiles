local M = {
    name = 'mark-signs',
    plug = {
        -- '/Volumes/work/git/mark-signs.nvim',
        'https://github.com/insanum/mark-signs.nvim',
    },
    priority = 5,
}

M.opts = {
    --builtin_marks = { '.', '^', '`', '\'', '"', '<', '>', '[', ']' },
    builtin_marks = { },
    sign_priority = { lower=10, upper=15, builtin=8 },
}

return M
