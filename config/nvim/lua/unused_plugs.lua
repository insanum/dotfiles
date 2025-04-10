return {

{
    'marcussimonsen/let-it-snow.nvim',
    cmd = 'LetItSnow',
    opts = {
        delay = 175,
    },
},

{
    'jackMort/ChatGPT.nvim',
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
    main = 'colorizer',
    opts = {},
},

{
    'nanozuki/tabby.nvim',
    event = 'VimEnter',
    dependencies = {
        'nvim-tree/nvim-web-devicons',
    },
    opts = {},
},

{
    'folke/todo-comments.nvim',
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
    event = 'VeryLazy',
},

{
    'TabbyML/vim-tabby',
    config = function()
        vim.g.tabby_node_binary = '/opt/homebrew/bin/node'
        vim.g.tabby_keybinding_accept = '<C-f>'
        vim.g.tabby_trigger_mode = 'auto'
    end,
},

{
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    opts = {},
},

{
    'junegunn/vim-easy-align',
    config = function()
        vim.keymap.set('x', 'ga', '<Plug>(EasyAlign)')
        --vim.keymap.set('n', 'ga', '<Plug>(EasyAlign)')
    end,
},

{
    'numToStr/FTerm.nvim',
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
    lazy = false,
    priority = 999,
    config = function()
        vim.cmd.colorscheme 'onedark'
    end,
},

{
    'rmehri01/onenord.nvim',
    lazy = false,
    priority = 999,
    config = function()
        vim.cmd.colorscheme 'onenord'
    end,
},

{
    'ellisonleao/gruvbox.nvim',
    lazy = false,
    priority = 999,
    config = function()
        vim.opt.background = 'dark'
        vim.cmd.colorscheme 'gruvbox'
    end,
},

}
