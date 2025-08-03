return {
    'Exafunction/windsurf.nvim',
    enabled = false,
    dependencies = {
        'nvim-lua/plenary.nvim',
    },
    event = 'BufEnter',
    config = function()
        -- force codeium to use socks5 proxy
        -- vim.env.HTTP_PROXY = 'socks5://127.0.0.1:9999'
        -- vim.env.HTTPS_PROXY = 'socks5://127.0.0.1:9999'
        -- vim.env.DEBUG_CODEIUM = 'debug'

        require('codeium').setup({
            enable_chat = true,
        })
    end
}
