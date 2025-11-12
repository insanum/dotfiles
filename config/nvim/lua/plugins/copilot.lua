local M = {}

M.setup = function(add)
    add({
        source = 'zbirenbaum/copilot.lua',
    })

    -- force copilot to use socks5 proxy
    -- vim.env.ALL_PROXY = 'socks5://127.0.0.1:9999'
    -- vim.env.HTTPS_PROXY = 'socks5://127.0.0.1:9999'
    -- vim.env.HTTP_PROXY = 'socks5://127.0.0.1:9999'

    require('copilot').setup({
        --copilot_model = 'gpt-4o',
        filetypes = {
            yaml = false,
            markdown = false,
        },
        suggestion = {
            enabled = false,
        },
        panel = {
            enabled = false,
        },
    })
end

return M
