return {
    'milanglacier/minuet-ai.nvim',
    enabled = false,
    dependencies = {
        'nvim-lua/plenary.nvim',
    },
    opts = {
        virtualtext = {
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
        provider = 'openai_fim_compatible',
        n_completions = 1, -- keep small for resource saving
        context_window = 512, -- start small for speed and increase
        provider_options = {
            openai_fim_compatible = {
                api_key = 'TERM',
                name = 'Ollama',
                end_point = 'http://localhost:11434/v1/completions',
                model = 'qwen2.5-coder:7b',
                --model = 'codellama:7b-code',
                --model = 'deepseek-coder-v2',
                optional = {
                    max_tokens = 56,
                    top_p = 0.9,
                },
            },
        },
    },
}
