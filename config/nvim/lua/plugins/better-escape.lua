return {
    'max397574/better-escape.nvim',
    enabled = true,
    config = function()
        require('better_escape').setup() -- 'jj' or 'jk' = <ESC>
    end,
}
