return {
    'CopilotC-Nvim/CopilotChat.nvim',
    dependencies = {
        'zbirenbaum/copilot.lua',
        'nvim-lua/plenary.nvim',
    },
    build = 'make tiktoken',
    opts = {
        model = 'claude-3.7-sonnet',
        highlight_headers = false,
        seperator = '---',
        error_header = '> [!ERROR] Error',
        mappings = {
            reset = {
                normal = '<C-r>',
                insert = '<C-r>',
            },
        },
    },
}
