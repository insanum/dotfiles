return {
    -- dir = '/Volumes/work/git/mark-signs.nvim',
    -- config = function()
    --     require('mark-signs').setup {
    --         builtin_marks = { '.', '^', '`', '\'', '"', '<', '>', '[', ']' },
    --         sign_priority = { lower=10, upper=15, builtin=8 },
    --     }
    -- end,
    'insanum/mark-signs.nvim',
    event = 'VeryLazy',
    config = function()
        require('mark-signs').setup {
            --builtin_marks = { '.', '^', '`', '\'', '"', '<', '>', '[', ']' },
            builtin_marks = { '.', '"', },
            sign_priority = { lower=10, upper=15, builtin=8 },
        }
    end,
}
