return {
    'echasnovski/mini.nvim',
    config = function()
        local starter = require('mini.starter')
        starter.setup({
            items = {
                starter.sections.sessions(10, true),
                starter.sections.recent_files(10, false, true),
                {
                    { name = 'Lazy', action = 'Lazy', section = 'Updaters'},
                    { name = 'Mason', action = 'Mason', section = 'Updaters'},
                },
                starter.sections.builtin_actions(),
            },
            content_hooks = {
                starter.gen_hook.aligning('center', 'center'),
                starter.gen_hook.adding_bullet('  '),
            },
            header = function()
                local banner = [[
      ████ ██████           █████     ██
     ███████████             █████  █
     █████████ ██████████████████ ███   ██████████
    █████████  ███    █████████████ █████ █████████████
   █████████ ██████████ █████████ █████ █████ ████ ████
 ███████████ ███    ███ █████████ █████ █████ ████ ████
██████  █████████████████████ ████ █████ █████ ████ █████]]
                return banner
            end,
        })

        -- Better Around/Inside textobjects
        -- Examples:
        --  - va)  - [V]isually select [A]round [)]paren
        --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
        --  - ci'  - [C]hange [I]nside [']quote
        require('mini.ai').setup({ n_lines = 500 })

        -- Add/delete/replace surroundings (brackets, quotes, etc.)
        -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
        -- - sd'   - [S]urround [D]elete [']quotes
        -- - sr)'  - [S]urround [R]eplace [)] [']
        require('mini.surround').setup()

        local animate = require('mini.animate')
        local animate_timing = animate.gen_timing.linear({
            duration = 100, -- msecs
            unit = 'total'
        })
        animate.setup({
            cursor = { timing = animate_timing },
            scroll = { timing = animate_timing },
            resize = { timing = animate_timing },
            open   = { timing = animate_timing },
            close  = { timing = animate_timing },
        })

        require('mini.align').setup()

        require('mini.bracketed').setup()

        require('mini.trailspace').setup()

        require('mini.comment').setup()

        require('mini.git').setup()
        require('mini.diff').setup()

        require('mini.splitjoin').setup()

        local indentscope = require('mini.indentscope')
        indentscope.setup({
            symbol='│',
            draw = {
                animation = indentscope.gen_animation.none(),
                --animation = indentscope.gen_animation.quadratic({ easing = 'out', duration = 10, unit = 'total' }),
            },
        })

        require('mini.files').setup({
            windows = {
                preview = true, -- show preview of file/directory under cursor
                width_focus = 40,
                width_nofocus = 40,
                width_preview = 40,
            },
        })

        vim.keymap.set('n', '<F12>', '<cmd>lua MiniFiles.open()<CR>', { desc = 'Mini Files', })

        require('mini.sessions').setup()

        vim.keymap.set('n', ',oo', '<cmd>lua MiniSessions.select(\'read\')<CR>', { desc = 'Open Session' })
        vim.keymap.set('n', ',od', '<cmd>lua MiniSessions.select(\'delete\')<CR>', { desc = 'Delete Session' })
        vim.keymap.set('n', ',os', function()
            local ok, res = pcall(vim.fn.input, {
                prompt = 'Save session as: ',
                cancelreturn = false,
            })
            if not ok or res == false then
                return nil
            end
            MiniSessions.write(res)
        end, { desc = 'Save Session' })

        require('mini.clue').setup({
            window = {
                delay = 0,
                config = {
                    width = 'auto',
                    border = 'single',
                },
            },
            triggers = {
                -- Leader triggers
                { mode = 'n', keys = '<leader>' },
                { mode = 'x', keys = '<leader>' },
                { mode = 'n', keys = ',' },
                { mode = 'x', keys = ',' },
                -- Built-in completion
                { mode = 'i', keys = '<C-x>' },
                -- `g` key
                { mode = 'n', keys = 'g' },
                { mode = 'x', keys = 'g' },
                -- Marks
                { mode = 'n', keys = "'" },
                { mode = 'n', keys = '`' },
                { mode = 'x', keys = "'" },
                { mode = 'x', keys = '`' },
                -- Registers
                { mode = 'n', keys = '"' },
                { mode = 'x', keys = '"' },
                { mode = 'i', keys = '<C-r>' },
                { mode = 'c', keys = '<C-r>' },
                -- Window commands
                { mode = 'n', keys = '<C-w>' },
                -- `z` key
                { mode = 'n', keys = 'z' },
                { mode = 'x', keys = 'z' },
            },
            clues = {
                require('mini.clue').gen_clues.builtin_completion(),
                require('mini.clue').gen_clues.g(),
                require('mini.clue').gen_clues.marks(),
                require('mini.clue').gen_clues.registers(),
                require('mini.clue').gen_clues.windows(),
                require('mini.clue').gen_clues.z(),
                { mode = 'n', keys = '<leader>o', desc = '+Obsidian' },
                { mode = 'n', keys = '<leader>q', desc = '+Quickfix' },
                { mode = 'n', keys = '<leader>s', desc = '+Search' },
                { mode = 'n', keys = '<leader>l', desc = '+LSP' },
                { mode = 'n', keys = '<leader>t', desc = '+Tab' },
                { mode = 'n', keys = '<leader>h', desc = '+Git' },
                { mode = 'n', keys = '<leader>x', desc = '+Trouble' },
                { mode = 'n', keys = ',o', desc = '+Sessions' },
            },
        })

        require('mini.jump2d').setup({
            view = {
                dim = true,
                n_steps_ahead = 0,
            },
        })

        vim.keymap.set(
            { 'o', 'x', 'n' },
            '<CR>',
            '<cmd>lua MiniJump2d.start(MiniJump2d.builtin_opts.single_character)<CR>',
            { desc = 'Jump anywhere' })

        require('mini.cursorword').setup()

        require('mini.icons').setup()

        local hi_words = require('mini.extra').gen_highlighter.words
        require('mini.hipatterns').setup({
            highlighters = {
                fixme = hi_words({ 'FIXME', 'Fixme', 'fixme', }, 'MiniHipatternsFixme'),
                xxx   = hi_words({ 'XXX', 'xxx' }, 'MiniHipatternsFixme'),
                todo  = hi_words({ 'TODO', 'Todo', 'todo' }, 'MiniHipatternsTodo'),
                hack  = hi_words({ 'HACK', 'Hack', 'hack' }, 'MiniHipatternsHack'),
                note  = hi_words({ 'NOTE', 'Note', 'note' }, 'MiniHipatternsNote'),
            },
        })

        require('mini.extra').setup()
        require('mini.pick').setup({
            mappings = {
                move_down         = '<C-j>',
                move_up           = '<C-k>',
                scroll_down       = '<C-d>',
                scroll_up         = '<C-u>',
                choose_in_split   = '<C-x>',
                choose_in_vsplit  = '<C-v>',
                choose_in_tabpage = '<C-t>',
            },
        })

        -- Search keymaps

        vim.keymap.set('n', '<leader>sf',
                       '<cmd>Pick files<CR>',
                       { desc = '[S]earch [F]iles' })

        vim.keymap.set('n', '<leader>se',
                       '<cmd>Pick explorer<CR>',
                       { desc = '[S]earch [E]xplorer' })

        vim.keymap.set('n', '<leader>sw',
                       '<cmd>Pick grep pattern=\'<cword>\'<CR>',
                       { desc = '[S]earch [G]rep live' })

        vim.keymap.set('n', '<leader>sg',
                       '<cmd>Pick grep_live<CR>',
                       { desc = '[S]earch [G]rep live' })

        vim.keymap.set('n', '<leader>/',
                       '<cmd>Pick buf_lines scope=\'current\'<CR>',
                       { desc = '[/] Search in current buffer' })

        vim.keymap.set('n', '<leader>s/',
                       '<cmd>Pick buf_lines scope=\'all\'<CR>',
                       { desc = '[S]earch [/] across all buffers' })

        vim.keymap.set('n', '<leader>sh',
                       '<cmd>Pick help<CR>',
                       { desc = '[S]earch [H]elp' })

        vim.keymap.set('n', '<leader>sk',
                       '<cmd>Pick keymaps<CR>',
                       { desc = '[S]earch [K]eymaps' })

        vim.keymap.set('n', '<leader>sd',
                       '<cmd>Pick diagnostic<CR>',
                       { desc = '[S]earch [D]iagnostics' })

        vim.keymap.set('n', '<leader>st',
                       '<cmd>Pick hipatterns<CR>',
                       { desc = '[S]earch [T]odos' })

        vim.keymap.set('n', '<leader>sm',
                       '<cmd>Pick marks<CR>',
                       { desc = '[S]earch [M]arks' })

        vim.keymap.set('n', '<leader>sc',
                       '<cmd>Pick commands<CR>',
                       { desc = '[S]earch [C]ommands' })

        vim.keymap.set('n', '<leader>sr',
                       '<cmd>Pick resume<CR>',
                       { desc = '[S]earch [R]esume' })

        vim.keymap.set('n', '<leader>so',
                       '<cmd>Pick oldfiles<CR>',
                       { desc = '[S]earch [O]ld (recent) files' })

        vim.keymap.set('n', '<leader><leader>',
                       '<cmd>Pick buffers<CR>',
                       { desc = '[ ] Search current buffers' })

        local pick_show_with_icons = function(buf_id, items, query)
            return MiniPick.default_show(buf_id, items, query,
                { show_icons = true })
        end

        MiniPick.registry.neovim_config = function()
            return MiniPick.builtin.cli(
                {
                    command = {
                        'rg',
                        '--follow', -- have to follow symlinks
                        '--files',
                    },
                },
                {
                    source = {
                        name = 'neovim_config',
                        show = pick_show_with_icons,
                        cwd = vim.fn.stdpath 'config',
                    },
                })
        end

        MiniPick.registry.registry = function()
            local items = vim.tbl_keys(MiniPick.registry)
            table.sort(items)
            local chosen_picker_name = MiniPick.start({
                source = {
                    items = items,
                    name = 'Registry',
                    choose = function() end
                },
            })
            if chosen_picker_name == nil then return end
            return MiniPick.registry[chosen_picker_name]()
        end

        -- Shortcut for searching your Neovim configuration files
        vim.keymap.set('n', '<leader>sn',
                       '<cmd>Pick neovim_config<CR>',
                       { desc = '[S]earch [N]eovim files' })

        -- Shortcut for searching the Pick registry and execute
        vim.keymap.set('n', '<leader>ss',
                       '<cmd>Pick registry<CR>',
                       { desc = '[S]earch [S]earch Pick registry' })

        -- FIXME: Add pickers for dealing with quickfix and location lists

        -- LSP keymaps

        vim.keymap.set('n', '<leader>lD',
                       '<cmd>Pick lsp scope=\'declaration\'<CR>',
                       { desc = '[L]SP [D]eclaration' })

        vim.keymap.set('n', '<leader>ld',
                       '<cmd>Pick lsp scope=\'definition\'<CR>',
                       { desc = '[L]SP [D]efinition' })

        vim.keymap.set('n', '<leader>lt',
                       '<cmd>Pick lsp scope=\'type_definition\'<CR>',
                       { desc = '[L]SP [T]ype Definition' })

        vim.keymap.set('n', '<leader>lr',
                       '<cmd>Pick lsp scope=\'references\'<CR>',
                       { desc = '[L]SP [R]eference' })

        vim.keymap.set('n', '<leader>li',
                       '<cmd>Pick lsp scope=\'implementation\'<CR>',
                       { desc = '[L]SP [I]mplementation' })

        vim.keymap.set('n', '<leader>ls',
                       '<cmd>Pick lsp scope=\'document_symbol\'<CR>',
                       { desc = '[L]SP [S]ymbols buffer' })

        vim.keymap.set('n', '<leader>lS',
                       '<cmd>Pick lsp scope=\'workspace_symbol\'<CR>',
                       { desc = '[L]SP [S]ymbols all buffers' })

        vim.keymap.set('n', '<leader>lR',
                       vim.lsp.buf.rename,
                       { desc = '[L]SP [R]ename symbol' })

        vim.keymap.set('n', '<leader>lh',
                       vim.lsp.buf.hover,
                       { desc = '[L]SP [H]over documentation' })

        vim.ui.select = MiniPick.ui_select

        -- HACK: mini.tabline
        -- Doesn't support tabs, just a dumb buffer list.

        -- HACK: mini.statusline
        -- Can't easily change separators to nerdfont glyphs.

        -- FIXME: mini.notify
        -- It needs to all messages like noice+nvim-notify.

        -- FIXME: mini.completion
        -- FIXME: mini.deps
    end,
}
