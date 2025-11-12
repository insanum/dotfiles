local M = {}

M.setup = function(add)
    add({
        source = 'kevinhwang91/nvim-bqf',
    })

    require('bqf').setup()
end

return M
