return {
    'saghen/blink.cmp',
    enabled = true,
    dependencies = {
        'rafamadriz/friendly-snippets'
    },
    version = '*',
    opts = {
        -- C-space: Open menu or open docs if already open
        -- C-j/C-k or Up/Down: Select next/previous item
        -- C-e: Hide menu
        -- C-k: Toggle signature help (if signature.enabled = true)
        --
        -- See :h blink-cmp-config-keymap for defining your own keymap
        keymap = {
            preset = 'default',
            ['<C-j>'] = { 'select_next', 'fallback' },
            ['<C-k>'] = { 'select_prev', 'fallback' },
            ['<C-l>'] = { 'select_and_accept' },
            ['<C-h>'] = { 'show_signature', 'hide_signature', 'fallback' },
            ['<C-u>'] = { 'scroll_documentation_up', 'fallback' },
            ['<C-d>'] = { 'scroll_documentation_down', 'fallback' },
        },
        appearance = {
            nerd_font_variant = 'mono',
        },
        -- (Default) Only show the documentation popup when manually triggered
        completion = {
            list = {
                selection = {
                    preselect = false,
                    auto_insert = false,
                },
            },
            menu = {
                border = 'single',
                direction_priority = { 's', 'n' },
                scrollbar = true,
                draw = {
                    align_to = 'none',
                    treesitter = {
                        'lsp',
                    },
                    columns = {
                        { 'label', 'label_description', gap = 1 },
                        { 'kind_icon', 'kind', gap = 1 },
                    },
                },
                auto_show = function()
                    if vim.bo.filetype == 'markdown' then
                        return false
                    end

                    return true
                end,
            },
            documentation = {
                auto_show = true,
                window = {
                    border = 'single',
                }
            },
            ghost_text = {
                enabled = true,
                show_with_selection = true,
                show_without_selection = true,
            },
        },
        cmdline = {
            keymap = {
                preset = 'inherit',
            },
            completion = {
                menu = {
                    auto_show = true,
                },
            },
        },
        signature = {
            enabled = true,
            window = {
                border = 'double',
            },
        },
        -- Default list of enabled providers defined so that you can extend it
        -- elsewhere in your config, without redefining it, due to `opts_extend`
        sources = {
            default = {
                'copilot',
                'codecompanion',
                -- 'minuet',
                'lsp',
                -- 'markdown',
                'buffer',
                'snippets',
                'path',
            },
            per_filetype = {
                markdown = { 'lsp', 'snippets', 'path' },
            },
            providers = {
                copilot = {
                    name = "copilot",
                    module = "blink-copilot",
                    score_offset = 100,
                    async = true,
                },
            },
        },
        fuzzy = {
            implementation = 'prefer_rust_with_warning',
        },
    },
    opts_extend = {
        'sources.default',
    },
}
