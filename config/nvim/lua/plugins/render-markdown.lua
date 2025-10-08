return {
    'MeanderingProgrammer/render-markdown.nvim',
    enabled = true,
    opts = {
        render_modes = true,
        debounce = 30,
        -- anti_conceal = { enabled = false },
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
            left_pad = 1,
            icons = { '󰉫 ', '󰉬 ', '󰉭 ', '󰉮 ', '󰉯 ', '󰉰 ' },
        },
        checkbox = {
            right_pad = 0,
            unchecked = {
                icon = '󰄱 ',
            },
            checked = {
                icon = '󰄵 ',
                --scope_highlight = '@markup.italic',
                scope_highlight = 'FoobarTaskChecked',
            },
            custom = {
                punted = {
                    raw = '[-]',
                    rendered = '✘ ',
                    highlight = 'RenderMarkdownChecked',
                    --scope_highlight = '@markup.strikethrough',
                    scope_highlight = 'FoobarTaskPunted',
                },
            },
            -- low priority to not override inline highlights
            scope_priority = 1,
        },
        code = {
            width = 'block',
            right_pad = 1,
        },
        pipe_table = {
            preset = 'round',
            border_virtual = true,
            cell = 'raw',
        },
    },
}
