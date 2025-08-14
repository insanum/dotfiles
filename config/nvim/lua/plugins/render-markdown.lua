return {
    'MeanderingProgrammer/render-markdown.nvim',
    enabled = true,
    opts = {
        --preset = 'obsidian',
        render_modes = true,
        file_types = {
            'markdown',
            'copilot-chat',
            'codecompanion',
            'Avante',
        },
        completions = {
            -- using blink messes with marksman and markdown_oxide
            --blink = { enabled = true },
            --lsp = { enabled = true },
        },
        heading = {
            border = true,
            border_virtual = true,
        },
        checkbox = {
            right_pad = 0,
        },
        code = {
            width = 'block',
            right_pad = 1,
        },
    },
}
