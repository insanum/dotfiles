local M = {
    now = true,
}

M.setup = function(add)
    add({
        source = 'yousefhadder/markdown-plus.nvim',
    })

    require("markdown-plus").setup()
end

return M
