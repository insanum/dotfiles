return {
    'olimorris/codecompanion.nvim',
    enabled = true,
    dependencies = {
        'nvim-lua/plenary.nvim',
        'nvim-treesitter/nvim-treesitter',
    },
    opts = {
        display = {
            chat = {
                --show_settings = true,
                show_header_separator = true,
            },
        },
        -- adapters = {
        --     opts = {
        --         allow_insecure = true,
        --         proxy = "socks5://127.0.0.1:9999",
        --     },
        -- },
        strategies = {
            chat = {
                adapter = 'copilot',
                opts = {
                    completion_provider = "blink",
                }
            },
            inline = {
                adapter = 'copilot',
            },
            cmd = {
                adapter = 'copilot',
            },
        },
    },
}
