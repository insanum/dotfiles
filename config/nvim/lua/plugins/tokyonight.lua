local M = {
    now = true,
}

M.setup = function(add)
    add({
        source = 'folke/tokyonight.nvim',
    })

    require('tokyonight').setup()
end

return M
