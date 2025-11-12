local M = {
    now = true,
}

M.setup = function(add)
    add({
        source = 'Darazaki/indent-o-matic',
    })

    require('indent-o-matic').setup({
        max_lines = 2048,
        standard_widths = { 4, 8 },
        skip_multiline = true,
    })
end

return M
