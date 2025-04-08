return {
    'saghen/blink.cmp',
    enabled = false,
    dependencies = {
        'rafamadriz/friendly-snippets'
    },
    version = '*',
    opts = {
        -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
        -- 'super-tab' for mappings similar to vscode (tab to accept)
        -- 'enter' for enter to accept
        -- 'none' for no mappings
        --
        -- All presets have the following mappings:
        -- C-space: Open menu or open docs if already open
        -- C-n/C-p or Up/Down: Select next/previous item
        -- C-e: Hide menu
        -- C-k: Toggle signature help (if signature.enabled = true)
        --
        -- See :h blink-cmp-config-keymap for defining your own keymap
        keymap = {
            preset = 'default',
            ['<C-j>'] = { 'select_next', 'fallback' },
            ['<C-k>'] = { 'select_prev', 'fallback' },
            ['<C-l>'] = { 'select_and_accept' },
        },
        appearance = {
            nerd_font_variant = 'mono',
        },
        -- (Default) Only show the documentation popup when manually triggered
        completion = {
            menu = {
                border = 'single',
                direction_priority = { 'n', 's' },
                scrollbar = true,
                draw = {
                    align_to = 'cursor',
                    treesitter = {
                        'lsp',
                    },
                    columns = {
                        { 'label', 'label_description', gap = 1 },
                        { 'kind_icon', 'kind', gap = 1 }
                    },
                },
            },
            documentation = {
                auto_show = false,
                window = {
                    border = 'single',
                }
            },
            ghost_text = {
                enabled = true,
            },
        },
        cmdline = {
            keymap = {
                -- recommended, as the default keymap will only show and select the next item
                ['<Tab>'] = { 'show', 'accept' },
                ['<C-j>'] = { 'select_next', 'fallback' },
                ['<C-k>'] = { 'select_prev', 'fallback' },
                ['<C-l>'] = { 'select_and_accept' },
            },
            completion = {
                menu = {
                    auto_show = true,
                },
            },
        },
        signature = {
            window = {
                border = 'single',
            },
        },
        -- Default list of enabled providers defined so that you can extend it
        -- elsewhere in your config, without redefining it, due to `opts_extend`
        sources = {
            default = {
                'windsurf',
                'lsp',
                'buffer',
                'snippets',
                'path',
            },
            providers = {
                windsurf = {
                    name = 'codeium',
                    module = 'blink.compat.source',
                    score_offset = 99,
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
