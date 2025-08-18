return {

{
    'marcussimonsen/let-it-snow.nvim',
    enabled = false,
    cmd = 'LetItSnow',
    opts = {
        delay = 175,
    },
},

{
    'jackMort/ChatGPT.nvim',
    enabled = false,
    event = 'VeryLazy',
    config = function()
      require('chatgpt').setup({})
    end,
    dependencies = {
      'MunifTanjim/nui.nvim',
      'nvim-lua/plenary.nvim',
      'folke/trouble.nvim',
      'nvim-telescope/telescope.nvim'
    }
},

{
    'nvim-telescope/telescope.nvim',
    enabled = false,
    event = 'VimEnter',
    branch = '0.1.x',
    dependencies = {
        'nvim-lua/plenary.nvim',
        { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make', },
        'nvim-telescope/telescope-ui-select.nvim',
        'nvim-tree/nvim-web-devicons',
    },
    config = function()
        -- Important keymaps to use while in Telescope are:
        --  - Insert mode: <c-/>
        --  - Normal mode: ?

        local actions = require("telescope.actions")
        local select_map = {
            i = { ['<C-j>'] = actions.move_selection_next,
                  ['<C-k>'] = actions.move_selection_previous, },
            n = { ['<C-j>'] = actions.move_selection_next,
                  ['<C-k>'] = actions.move_selection_previous, },
        }
        --local tab_drop_map = {
        --  i = { ['<CR>'] = actions.select_tab_drop },
        --  n = { ['<CR>'] = actions.select_tab_drop },
        --}
        require('telescope').setup {
            -- You can put your default mappings / updates / etc. in here
            --  All the info you're looking for is in `:help telescope.setup()`
            defaults = {
                mappings = select_map,
                vimgrep_arguments = {
                    "rg",
                    "--color=never",
                    "--no-heading",
                    "--with-filename",
                    "--line-number",
                    "--column",
                    "--smart-case",
                    "--follow",
                },
            },
            pickers = {
                buffers = {
                    sort_mru = true,
                },
                -- buffers    = { mappings = tab_drop_map, },
                -- quickfix   = { mappings = tab_drop_map, },
                -- marks      = { mappings = tab_drop_map, },
                -- find_files = { mappings = tab_drop_map, },
            },
            extensions = {
                ['ui-select'] = {
                    require('telescope.themes').get_dropdown(),
                },
            },
        }

        -- enable Telescope extensions which should be installed by default
        pcall(require('telescope').load_extension, 'fzf')
        pcall(require('telescope').load_extension, 'ui-select')

        local builtin = require 'telescope.builtin'
        vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
        vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
        vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
        vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
        vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
        vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
        vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
        vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
        vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

        vim.keymap.set('n', '<leader>sf',
            function()
                builtin.find_files({ follow = true })
            end,
            { desc = '[S]earch [F]iles' })

        vim.keymap.set('n', '<leader>/',
            function()
                local drop_theme = require('telescope.themes').get_dropdown({ winblend = 10, previewer = false })
                builtin.current_buffer_fuzzy_find(drop_theme)
            end,
            { desc = '[/] Fuzzily search in current buffer' })

        vim.keymap.set('n', '<leader>s/',
            function()
                builtin.live_grep({ grep_open_files = true, prompt_title = 'Live Grep in Open Files' })
            end,
            { desc = '[S]earch [/] in Open Files' })

        -- Shortcut for searching your Neovim configuration files
        vim.keymap.set('n', '<leader>sn',
            function()
                builtin.find_files({ follow = true, cwd = vim.fn.stdpath 'config' })
            end,
            { desc = '[S]earch [N]eovim files' })

        -- Workaround for bug where Telescope enters Insert mode on selection:
        -- https://github.com/nvim-telescope/telescope.nvim/issues/2027
        vim.api.nvim_create_autocmd('WinLeave', {
            callback = function()
                if vim.bo.ft == 'TelescopePrompt' and vim.fn.mode() == 'i' then
                    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'i', false)
                end
            end,
        })
    end,
},

{
    'ThePrimeagen/git-worktree.nvim',
    enabled = false,
    event = 'VeryLazy',
    config = function()
        --vim.g.git_worktree_log_level = 'debug'
        require('git-worktree').setup({
            change_directory_command = 'tcd',
            update_on_change_command = 'Telescope find_files',
            --update_on_change_command = 'Pick files',
            --autopush = true,
        })
        require('telescope').load_extension('git_worktree')
        vim.keymap.set('n', '<leader>hw', '<cmd>Telescope git_worktree<CR>', { desc = 'git Worktree switch' })
        vim.keymap.set('n', '<leader>hW', require('telescope').extensions.git_worktree.create_git_worktree, { desc = 'git Worktree create' })
    end,
},

{
    'NvChad/nvim-colorizer.lua',
    enabled = false,
    main = 'colorizer',
    opts = {},
},

{
    'nanozuki/tabby.nvim',
    enabled = false,
    event = 'VimEnter',
    dependencies = {
        'nvim-tree/nvim-web-devicons',
    },
    opts = {},
},

{
    'folke/todo-comments.nvim',
    enabled = false,
    event = 'VimEnter',
    dependencies = {
        'nvim-lua/plenary.nvim'
    },
    opts = {
        signs = false
    },
},

{
    "folke/trouble.nvim",
    enabled = false,
    opts = {
        focus = true,
    },
    cmd = "Trouble",
    keys = {
        {
            "<leader>xx",
            "<cmd>Trouble diagnostics toggle win.type=split win.position=bottom win.relative=win<cr>",
            desc = "Diagnostics (Trouble)",
        },
        {
            "<leader>xt",
            "<cmd>Trouble todo toggle win.type=split win.position=bottom win.relative=win<cr>",
            desc = "Todos (Trouble)",
        },
    },
},

{
    'ggandor/leap.nvim',
    enabled = false,
    keys = {
        { 's', '<Plug>(leap-forward)', desc = 'Leap forward' },
        { 'S', '<Plug>(leap-backward)', desc = 'Leap backward' },
    },
},

{
    'lewis6991/gitsigns.nvim',
    enabled = false,
    opts = {
        on_attach = function(bufnr)
            local gs = package.loaded.gitsigns

            local function map(mode, l, r, opts)
                opts = opts or {}
                opts.buffer = bufnr
                vim.keymap.set(mode, l, r, opts)
            end

            -- Navigation

            map({ 'n', 'v' }, ']c',
                function()
                    if vim.wo.diff then
                        return ']c'
                    end
                    vim.schedule(function()
                        gs.next_hunk()
                    end)
                    return '<Ignore>'
                end,
                { expr = true, desc = 'Jump to next hunk' })

            map({ 'n', 'v' }, '[c',
                function()
                    if vim.wo.diff then
                        return '[c'
                    end
                    vim.schedule(function()
                        gs.prev_hunk()
                    end)
                    return '<Ignore>'
                end,
                { expr = true, desc = 'Jump to previous hunk' })

            -- Actions (visual mode)

            map('v', '<leader>hs',
                function()
                    gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
                end,
                { desc = 'stage git hunk' })

            map('v', '<leader>hr',
                function()
                    gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
                end,
                { desc = 'reset git hunk' })

            -- Actions (normal mode)

            map('n', '<leader>hs', gs.stage_hunk, { desc = 'git Stage hunk' })
            map('n', '<leader>hr', gs.reset_hunk, { desc = 'git Reset hunk' })
            map('n', '<leader>hS', gs.stage_buffer, { desc = 'git Stage buffer' })
            map('n', '<leader>hu', gs.undo_stage_hunk, { desc = 'git Undo stage hunk' })
            map('n', '<leader>hR', gs.reset_buffer, { desc = 'git Reset buffer' })
            map('n', '<leader>hp', gs.preview_hunk, { desc = 'git Preview hunk' })
            map('n', '<leader>hd', gs.diffthis, { desc = 'git Diff against index' })

            map('n', '<leader>hb',
                function()
                    gs.blame_line({ full = false })
                end,
                { desc = 'git Blame line' })

            --[[
            map('n', '<leader>hD',
                function()
                    gs.diffthis('~')
                end,
                { desc = 'git Diff against last commit' })
            --]]

            -- Toggles
            --map('n', '<leader>hB', gs.toggle_current_line_blame, { desc = 'toggle git blame line' })
            --map('n', '<leader>hL', gs.toggle_deleted, { desc = 'toggle git show deleted' })

            -- Text object
            map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'git Select hunk' })
        end,
    },
},

{
    'folke/which-key.nvim',
    enabled = false,
    event = 'VimEnter',
    opts = {
        icons = {
            -- using a Nerd Font...
            mappings = true,
            keys = {}
        },

        spec = {
            { '<leader>c', group = '[C]ode', mode = { 'n', 'x' } },
            { '<leader>d', group = '[D]ocument' },
            { '<leader>r', group = '[R]ename' },
            { '<leader>s', group = '[S]earch' },
            { '<leader>w', group = '[W]orkspace' },
            { '<leader>t', group = '[T]oggle' },
            { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
        },
    },
},

{
    'jedrzejboczar/possession.nvim',
    enabled = false,
    opts = {
        commands = {
            save = 'PoSave',
            load = 'PoLoad',
            close = 'PoClose',
            delete = 'PoDelete',
            show = 'PoShow',
            list = 'PoList',
            migrate = 'PoMigrate',
        },
    },
    keys = {
        { ',o', '<cmd>Telescope possession list<CR>', desc = 'Possession' },
    },
    config = function(_, opts)
        require('possession').setup(opts)
        require('telescope').load_extension('possession')
    end,
},

{
    'chentoast/marks.nvim',
    enabled = false,
    event = 'VeryLazy',
    config = function()
        require('marks').setup {
            builtin_marks = { '.', '<', '>', '^' },
            sign_priority = { lower=10, upper=15, builtin=8, bookmark=20 },
        }
    end,
},

{
    "LintaoAmons/bookmarks.nvim",
    enabled = false,
    dependencies = {
        'nvim-telescope/telescope.nvim',
        --'stevearc/dressing.nvim',
    },
},

{
    'debugloop/telescope-undo.nvim',
    enabled = false,
    dependencies = { -- note how they're inverted to above example
        {
            'nvim-telescope/telescope.nvim',
            dependencies = {
                'nvim-lua/plenary.nvim'
            },
        },
    },
    keys = {
        {
            '<leader>u',
            '<cmd>Telescope undo<CR>',
            desc = 'undo history',
        },
    },
    opts = {
        extensions = {
            undo = {
                use_delta = false,
            },
        },
    },
    config = function(_, opts)
        require('telescope').setup(opts)
        require('telescope').load_extension('undo')
    end,
},

{
    'tpope/vim-fugitive',
    enabled = false,
    event = 'VeryLazy',
},

{
    'TabbyML/vim-tabby',
    enabled = false,
    config = function()
        vim.g.tabby_node_binary = '/opt/homebrew/bin/node'
        vim.g.tabby_keybinding_accept = '<C-f>'
        vim.g.tabby_trigger_mode = 'auto'
    end,
},

{
    'lukas-reineke/indent-blankline.nvim',
    enabled = false,
    main = 'ibl',
    opts = {},
},

{
    'junegunn/vim-easy-align',
    enabled = false,
    config = function()
        vim.keymap.set('x', 'ga', '<Plug>(EasyAlign)')
        --vim.keymap.set('n', 'ga', '<Plug>(EasyAlign)')
    end,
},

{
    'numToStr/FTerm.nvim',
    enabled = false,
    config = function()
        require'FTerm'.setup({
            --env = { TERM = 'tmux-256color' },
            border = 'double',
            dimensions  = {
                height = 0.8,
                width = 0.8,
            },
        })
    end,
},

{
    'navarasu/onedark.nvim',
    enabled = false,
    lazy = false,
    priority = 999,
    config = function()
        vim.cmd.colorscheme 'onedark'
    end,
},

{
    'rmehri01/onenord.nvim',
    enabled = false,
    lazy = false,
    priority = 999,
    config = function()
        vim.cmd.colorscheme 'onenord'
    end,
},

{
    'ellisonleao/gruvbox.nvim',
    enabled = false,
    lazy = false,
    priority = 999,
    config = function()
        vim.opt.background = 'dark'
        vim.cmd.colorscheme 'gruvbox'
    end,
},

{
    'Saghen/blink.compat',
    enabled = false,
    opts = { },
},

{
    'iguanacucumber/magazine.nvim',
    enabled = false,
    name = 'nvim-cmp',
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
                { name = 'copilot',       max_item_count = 10 },
                { name = 'codecompanion', max_item_count = 10 },
                { name = 'minuet',        max_item_count = 10 },
                { name = 'codeium',       max_item_count = 10 },
                { name = 'cody',          max_item_count = 10 },
                { name = 'nvim_lsp',      max_item_count = 10 },
                { name = 'luasnip',       max_item_count = 10 },
                { name = 'path',          max_item_count = 10 },
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
                        Copilot = '✨',
                        openai = '✨',
                        Minuet = '✨',
                        Codeium = '✨',
                        Cody = '✨',
                    },
                })
            },

            performance = {
                fetching_timeout = 2000,
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
                ['<C-k>'] = cmp.mapping(cmp.mapping.select_next_item(cmp_behavior),
                                        { 'i', 's', 'c' }),
                ['<C-j>'] = cmp.mapping(cmp.mapping.select_prev_item(cmp_behavior),
                                        { 'i', 's', 'c' }),
                ['<C-l>'] = cmp.mapping(cmp.mapping.confirm({ select = true }),
                                        { 'i', 's', 'c' }),

                --['<C-Space>'] = cmp.mapping.complete(),
                ['<C-Space>'] = cmp.mapping.complete({
                    config = {
                        sources = {
                            { name = 'copilot' },
                            { name = 'minuet' },
                            { name = 'codeium' },
                            { name = 'cody' },
                        },
                    },
                }),

                -- Snippets: jump to next expansion location
                ['<C-n>'] = cmp.mapping(function()
                    if luasnip.expand_or_locally_jumpable() then
                        luasnip.expand_or_jump()
                    end
                end, { 'i', 's' }),

                -- Snippets: jump to previous expansion location
                ['<C-p>'] = cmp.mapping(function()
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
},

{
    'zbirenbaum/copilot-cmp',
    enabled = false,
    opts = {},
},

{
    'sourcegraph/sg.nvim', -- Cody
    enabled = false,
    dependencies = {
        'nvim-lua/plenary.nvim',
        --'nvim-telescope/telescope.nvim',
    },
    config = function()
        -- force cody to use socks5 proxy
        -- vim.env.HTTP_PROXY = 'socks5://127.0.0.1:9999'
        -- vim.env.HTTPS_PROXY = 'socks5://127.0.0.1:9999'

        require('sg').setup({
        })
    end,
},

{
    'Exafunction/windsurf.nvim',
    enabled = false,
    dependencies = {
        'nvim-lua/plenary.nvim',
    },
    event = 'BufEnter',
    config = function()
        -- force codeium to use socks5 proxy
        -- vim.env.HTTP_PROXY = 'socks5://127.0.0.1:9999'
        -- vim.env.HTTPS_PROXY = 'socks5://127.0.0.1:9999'
        -- vim.env.DEBUG_CODEIUM = 'debug'

        require('codeium').setup({
            enable_chat = true,
        })
    end
},

{
    '3rd/image.nvim',
    enabled = false,
    build = false,
    opts = {
        processor = 'magick_cli',
        integrations = {
            markdown = {
                enabled = true,
                only_render_image_at_cursor = true,
                only_render_image_at_cursor_mode = 'popup',
                resolve_image_path = function(document_path, image_path, fallback)
                    local dir1 = vim.fn.expand('/Volumes/work/notes/attachments')
                    local dir2 = vim.fn.expand('/Volumes/work/notes/assets')

                    -- check if the relative/absolute path exists
                    if vim.fn.filereadable(image_path) == 1 then
                        return image_path
                    end

                    -- check if the constructed paths exists

                    local new_image_path = dir1 .. '/' .. image_path
                    if vim.fn.filereadable(new_image_path) == 1 then
                        return new_image_path
                    end

                    new_image_path = dir2 .. '/' .. image_path
                    if vim.fn.filereadable(new_image_path) == 1 then
                        return new_image_path
                    end

                    -- else fallback to default behavior
                    return fallback(document_path, image_path)
                end,
            },
        },
    },
},

{
    'j-morano/buffer_manager.nvim',
    enabled = false,
    event = 'VeryLazy',
    dependencies = {
        'nvim-lua/plenary.nvim',
    },
    opts = {
        select_menu_item_commands = {
            edit = {
                key = '<CR>',
                command = 'edit'
            },
            v = {
                key = '<C-v>',
                command = 'vsplit'
            },
            h = {
                key = '<C-x>',
                command = 'split'
            }
        },
        win_extra_options = {
            signcolumn = 'no',
        },
        show_indicators = 'before',
    },
    config = function(_, opts)
        require('buffer_manager').setup(opts)
        local bm_ui = require('buffer_manager.ui')
        local keys = '1234567890'

        vim.keymap.set('n', ';', bm_ui.toggle_quick_menu,
                       { desc = 'Buffer Manager' })

        for i = 1, #keys do
            local key = keys:sub(i,i)
            vim.keymap.set('n', string.format('<leader>%s', key),
                function() bm_ui.nav_file(i) end,
                { desc = string.format('Buffer Manager: Goto buffer %s', key) })
        end
    end,
},

{
    'vuciv/golf',
    enabled = false,
},

{
    'max397574/better-escape.nvim',
    enabled = false,
    config = function()
        require('better_escape').setup() -- 'jj' or 'jk' = <ESC>
    end,
},

{
    'jakobkhansen/journal.nvim',
    enabled = false,
    opts = {
        root = '/Volumes/work/notes/Journal',
        filetype = 'md',
        journal = {
            entries = {
                day = {
                    format = '%Y-%m-%d',
                    template = '\n# %a %m/%d/%Y\n\n',
                },
                week = {
                    format = '%Y-w%W',
                    -- template = '\n# %Y (w%W)\n\n',
                    template = function(date)
                        local sunday = date:relative({ day = 6 })
                        local end_date = os.date('%m/%d', os.time(sunday.date))
                        return '\n# %Y %m/%d-' .. end_date .. ' (w%W)\n\n'
                    end,
                },
                month = {
                    format = '%Y-%m',
                    template = '\n# %Y-%m (%b)\n\n',
                },
                year = {
                    format = '%Y',
                    template = '\n# %Y\n\n',
                },
            },
        },
    },
}

}
