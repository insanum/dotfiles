return {
    'sourcegraph/sg.nvim', -- Cody
    enabled = false,
    dependencies = {
        'nvim-lua/plenary.nvim',
        --'nvim-telescope/telescope.nvim',
    },
    config = function()
        -- force cody to use socks5 proxy
        vim.env.HTTP_PROXY = 'socks5://127.0.0.1:9999'
        vim.env.HTTPS_PROXY = 'socks5://127.0.0.1:9999'
        require('sg').setup({
        })
    end,
}
