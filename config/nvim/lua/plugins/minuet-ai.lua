return {
    'milanglacier/minuet-ai.nvim',
    enabled = false,
    dependencies = {
        'nvim-lua/plenary.nvim',
    },
    opts = {
        notify = 'verbose',
        request_timeout = 2,
        cmp = {
            enable_auto_complete = true,
        },
        virtualtext = {
            show_on_completion_menu = true,
            auto_trigger_ft = { 'c', 'python', 'sh', 'rust', 'js' },
            keymap = {
                -- accept whole completion
                accept = '<C-l>',
                -- accept one line
                --accept_line = '<A-a>',
                -- accept n lines (prompts for number)
                -- e.g. "A-z 2 CR" will accept 2 lines
                --accept_n_lines = '<A-z>',
                -- Cycle to prev completion item, or manually invoke completion
                prev = '<C-k>',
                -- Cycle to next completion item, or manually invoke completion
                next = '<C-j>',
                dismiss = '<C-c>',
            },
        },
        -- proxy = 'socks5://127.0.0.1:9999',
        provider = 'openai',
        provider_options = {
            openai = {
                api_key = 'OPENAI_API_KEY',
                model = 'gpt-4o-mini',
            },
        },
    },
}
