local M = {}

M.setup = function(add)
    add({
        source = 'akinsho/toggleterm.nvim',
    })

    require('toggleterm').setup({
        shade_terminals = false,
    })
end

return M
