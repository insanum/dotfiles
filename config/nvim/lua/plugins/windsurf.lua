-- This version of Codeium is Lua based and sends all generation to nvim-cmp.
-- This results in the ghost text not conflicting with nvim-cmp text. This one
-- does support the ':Codeium Chat' command which opens a browser window.
return {
    'Exafunction/windsurf.nvim',
    enabled = true,
    dependencies = {
        'nvim-lua/plenary.nvim',
        'hrsh7th/nvim-cmp',
    },
    event = 'BufEnter',
    config = function()
        -- force codeium to use socks5 proxy
        vim.env.HTTP_PROXY = 'socks5://127.0.0.1:9999'
        vim.env.HTTPS_PROXY = 'socks5://127.0.0.1:9999'
        --vim.env.DEBUG_CODEIUM = 'debug'

        require('codeium').setup({
            enable_chat = true,
        })
    end
}
