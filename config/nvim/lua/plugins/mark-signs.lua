local M = {
    now = true,
}

M.setup = function(add)
    add({
        --source = '/Volumes/work/git/mark-signs.nvim',
        source = 'insanum/mark-signs.nvim',
    })

    require('mark-signs').setup {
        --builtin_marks = { '.', '^', '`', '\'', '"', '<', '>', '[', ']' },
        builtin_marks = { },
        sign_priority = { lower=10, upper=15, builtin=8 },
    }
end

return M
