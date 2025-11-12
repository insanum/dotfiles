local M = {}

M.setup = function(add)
    add({
        source = 'folke/snacks.nvim',
    })

    require('snacks').setup({
        image = {
            enabled = true,
            doc = {
                inline = true,
            },
        },
    })
end

return M
