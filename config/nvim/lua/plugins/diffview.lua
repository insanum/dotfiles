local M = {}

M.setup = function(add)
    add({
        source = 'sindrets/diffview.nvim',
    })

    require('diffview').setup()
end

return M
