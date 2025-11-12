local M = {}

M.setup = function(add)
    add({
        source = 'FabijanZulj/blame.nvim',
    })

    require('blame').setup()
end

return M
