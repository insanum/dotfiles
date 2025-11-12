local M = {
    now = true,
}

M.setup = function(add)
    add({
        source = 'navarasu/onedark.nvim',
    })

    require('onedark').setup()
end

return M
