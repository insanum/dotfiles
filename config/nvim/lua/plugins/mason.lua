local M = {}

M.setup = function(add)
    add({
        source = 'williamboman/mason.nvim',
    })

    require('mason').setup()
end

return M
