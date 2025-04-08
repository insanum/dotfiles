return {
    'zbirenbaum/copilot.lua',
    config = function()
        -- force copilot to use socks5 proxy
        vim.env.ALL_PROXY = 'socks5://127.0.0.1:9999'

        require('copilot').setup({
            copilot_model = 'gpt-4o-copilot',
            suggestion = {
                enabled = false,
            },
            panel = {
                enabled = false,
            },
        })
    end
}
