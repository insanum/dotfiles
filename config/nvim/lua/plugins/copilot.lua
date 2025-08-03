return {
    'zbirenbaum/copilot.lua',
    enabled = true,
    config = function()
        -- force copilot to use socks5 proxy
        -- vim.env.ALL_PROXY = 'socks5://127.0.0.1:9999'
        -- vim.env.HTTPS_PROXY = 'socks5://127.0.0.1:9999'
        -- vim.env.HTTP_PROXY = 'socks5://127.0.0.1:9999'

        require('copilot').setup({
            --copilot_model = 'gpt-4o',
            suggestion = {
                enabled = false,
            },
            panel = {
                enabled = false,
            },
        })
    end
}
