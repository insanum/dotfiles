return {
    'CopilotC-Nvim/CopilotChat.nvim',
    enabled = false,
    dependencies = {
        'zbirenbaum/copilot.lua',
        'nvim-lua/plenary.nvim',
    },
    build = 'make tiktoken',
    opts = {
        model = 'claude-sonnet-4',
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
