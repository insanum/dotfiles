local M = {
    name = 'copilot',
    plug = {
        'https://github.com/zbirenbaum/copilot.lua',
    },
    priority = 60,
}

M.opts = {
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
}

M.post_setup = function()
    -- force copilot to use socks5 proxy
    -- vim.env.ALL_PROXY = 'socks5://127.0.0.1:9999'
    -- vim.env.HTTPS_PROXY = 'socks5://127.0.0.1:9999'
    -- vim.env.HTTP_PROXY = 'socks5://127.0.0.1:9999'
end

return M
