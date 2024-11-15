return {
    'iguanacucumber/magazine.nvim',
    name = "nvim-cmp",
    --'hrsh7th/nvim-cmp',

    event = 'InsertEnter',
    dependencies = {
        {
            'L3MON4D3/LuaSnip',
            build = 'make install_jsregexp',
            dependencies = {
                {
                    'rafamadriz/friendly-snippets',
                    config = function()
                        require('luasnip.loaders.from_vscode').lazy_load()
                    end,
                },
            },
        },

        'saadparwaiz1/cmp_luasnip',

        --'hrsh7th/cmp-nvim-lsp',
        { 'iguanacucumber/mag-nvim-lsp', name = 'cmp-nvim-lsp', opts = {} },

        --'hrsh7th/cmp-buffer',
        { 'iguanacucumber/mag-buffer', name = 'cmp-buffer' },

        'hrsh7th/cmp-path',
        --'https://codeberg.org/FelipeLema/cmp-async-path',

        -- 'hrsh7th/cmp-cmdline',
        { 'iguanacucumber/mag-cmdline', name = 'cmp-cmdline' },

        --{ 'iguanacucumber/mag-nvim-lua', name = 'cmp-nvim-lua' },

        'onsails/lspkind.nvim',
    },

    config = function()
        local cmp = require('cmp')
        local luasnip = require('luasnip')

        luasnip.config.setup({})

        -- Insert or Select
        local cmp_behavior = { behavior = cmp.SelectBehavior.Select }

        cmp.setup({
            snippet = {
                expand = function(args)
                    luasnip.lsp_expand(args.body)
                end,
            },

            window = {
                completion = cmp.config.window.bordered(),
                documentation = cmp.config.window.bordered(),
            },

            sources = cmp.config.sources({
                --{ name = 'codeium' }, -- 'codeium.nvim'
                { name = 'cody' }, -- 'sg.nvim'
                { name = 'nvim_lsp' },
                { name = 'luasnip' },
                { name = 'path' },
                --{ name = 'async_path' },
            }, {
                { name = 'buffer' },
            }),

            formatting = {
                format = require('lspkind').cmp_format({
                    mode = 'symbol_text',
                    preset = 'default',
                    maxwidth = 50,
                    ellipsis_char = '...',
                    show_labelDetails = false,
                    menu = {},
                    symbol_map = {
                        Codeium = '✨',
                        Cody = '✨',
                    },
                })
            },

            experimental = {
                ghost_text = true -- can conflict with AI generated text
            },

            view = {
                entries = {
                    name = 'custom',
                    selection_order = 'near_cursor',
                    vertical_positioning = 'above',
                },
            },

            mapping = cmp.mapping.preset.insert({
                ['<C-k>'] = cmp.mapping.select_next_item(cmp_behavior),
                ['<C-j>'] = cmp.mapping.select_prev_item(cmp_behavior),
                ['<C-y>'] = cmp.mapping.confirm({ select = true }),

                --['<C-Space>'] = cmp.mapping.complete(),
                ["<C-Space>"] = cmp.mapping.complete({
                    config = {
                        sources = {
                            { name = "cody" },
                        },
                    },
                }),

                -- Snippets: jump to next expansion location
                ['<C-l>'] = cmp.mapping(function()
                    if luasnip.expand_or_locally_jumpable() then
                        luasnip.expand_or_jump()
                    end
                end, { 'i', 's' }),

                -- Snippets: jump to previous expansion location
                ['<C-h>'] = cmp.mapping(function()
                    if luasnip.locally_jumpable(-1) then
                        luasnip.jump(-1)
                    end
                end, { 'i', 's' }),
            }),
        })

        cmp.setup.cmdline({ '/', '?' }, {
            mapping = cmp.mapping.preset.cmdline(),
            sources = {
                { name = 'buffer' }
            }
        })

        cmp.setup.cmdline(':', {
            mapping = cmp.mapping.preset.cmdline(),
            sources = cmp.config.sources({
                { name = 'path' }
            }, {
                {
                    name = 'cmdline',
                    option = {
                        ignore_cmds = { 'Man', '!' }
                    }
                }
            })
        })
    end,
}
