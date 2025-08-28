return {
    'yetone/avante.nvim',
    enabled = false,
    --build = 'make BUILD_FROM_SOURCE=true',
    build = 'make',
    event = 'VeryLazy',
    dependencies = {
        'nvim-lua/plenary.nvim',
        'MunifTanjim/nui.nvim',
        'nvim-mini/mini.pick',
        'nvim-tree/nvim-web-devicons',
        'zbirenbaum/copilot.lua',
    },
    opts = {
        provider = 'copilot',
        behaviour = {
            auto_suggestions = false,
        },
        windows = {
            ask = {
                start_insert = false,
            },
        },
    },
}
