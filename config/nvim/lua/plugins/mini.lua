local M = {
    name = 'mini',
    setup = false,
    plug = {
        'https://github.com/nvim-mini/mini.nvim',
    },
    priority = 2,
}

M.post_setup = function()
    ---------------------------------------------------------------------
    -- mini.starter -----------------------------------------------------
    ---------------------------------------------------------------------

    local starter = require('mini.starter')
    starter.setup({
        items = {
            starter.sections.sessions(10, true),
            -- starter.sections.recent_files(10, false, true),
            -- {
            --     --{ name = 'Lazy', action = 'Lazy', section = 'Updaters'},
            --     { name = 'Mason', action = 'Mason', section = 'Updaters'},
            -- },
            -- starter.sections.builtin_actions(),
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
        footer = '',
    })

    ---------------------------------------------------------------------
    -- mini.x (NO CONFIG) -----------------------------------------------
    ---------------------------------------------------------------------

    require('mini.align').setup()

    require('mini.bracketed').setup()

    require('mini.comment').setup()

    require('mini.cursorword').setup()

    require('mini.extra').setup()

    require('mini.icons').setup()

    -- require('mini.splitjoin').setup()

    require('mini.trailspace').setup()

    require('mini.git').setup()

    ---------------------------------------------------------------------
    -- mini.keymap ------------------------------------------------------
    ---------------------------------------------------------------------

    local keymap = require('mini.keymap')
    keymap.setup()

    local mode = { 'i', 'c', 'x', 's' }
    -- map_combo(mode, 'jj', '<BS><BS><Esc>')
    keymap.map_combo(mode, 'jk', '<BS><BS><Esc>')
    -- keymap.map_combo(mode, 'kj', '<BS><BS><Esc>')

    ---------------------------------------------------------------------
    -- mini.diff --------------------------------------------------------
    ---------------------------------------------------------------------

    require('mini.diff').setup({
        view = {
            signs = { add = '▒', change = '▒', delete = '▒' },
            --signs = { add = '┃', change = '┃', delete = '━', },
            priority = 6,
        },
    })

    ---------------------------------------------------------------------
    -- mini.ai ----------------------------------------------------------
    ---------------------------------------------------------------------

    -- Better Around/Inside textobjects
    -- Examples:
    --   va)  - [V]isually select [A]round [)]paren
    --   yinq - [Y]ank [I]nside [N]ext [Q]uote
    --   ci'  - [C]hange [I]nside [']quote
    --   g[`  - [G]oto [\[]previous [`]backtick
    --   g[)  - [G]oto [\]]next [)]paren
    require('mini.ai').setup({ n_lines = 500 })

    ---------------------------------------------------------------------
    -- mini.surround ----------------------------------------------------
    ---------------------------------------------------------------------

    -- Add/delete/replace surroundings (brackets, quotes, etc.)
    --   saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
    --   sd'   - [S]urround [D]elete [']quotes
    --   sr)'  - [S]urround [R]eplace [)] [']
    require('mini.surround').setup()
    vim.keymap.set({ 'n', 'x' }, 's', '<Nop>')

    ---------------------------------------------------------------------
    -- mini.animate -----------------------------------------------------
    ---------------------------------------------------------------------

    -- Enable mini.animate if not using ghostty with a cursor shader!

    -- local animate = require('mini.animate')
    -- local animate_timing = animate.gen_timing.linear({
    --     duration = 100, -- msecs
    --     unit = 'total'
    -- })
    -- animate.setup({
    --     cursor = { timing = animate_timing },
    --     scroll = { timing = animate_timing },
    --     resize = { timing = animate_timing },
    --     open   = { timing = animate_timing },
    --     close  = { timing = animate_timing },
    -- })

    ---------------------------------------------------------------------
    -- mini.indentscope -------------------------------------------------
    ---------------------------------------------------------------------

    local indentscope = require('mini.indentscope')
    indentscope.setup({
        symbol='│',
        draw = {
            animation = indentscope.gen_animation.none(),
            --animation = indentscope.gen_animation.quadratic({ easing = 'out', duration = 10, unit = 'total' }),
        },
    })

    ---------------------------------------------------------------------
    -- mini.sessions ----------------------------------------------------
    ---------------------------------------------------------------------

    require('mini.sessions').setup({
        autowrite = false,
    })

    ---------------------------------------------------------------------
    -- mini.jump --------------------------------------------------------
    ---------------------------------------------------------------------

    require('mini.jump').setup()
    vim.api.nvim_set_hl(0, 'MiniJump', { link='ErrorMsg' })

    ---------------------------------------------------------------------
    -- mini.jump2d ------------------------------------------------------
    ---------------------------------------------------------------------

    require('mini.jump2d').setup({
        view = {
            dim = true,
            n_steps_ahead = 1,
        },
    })

    ---------------------------------------------------------------------
    -- mini.hipatterns --------------------------------------------------
    ---------------------------------------------------------------------

    local hi_words = require('mini.extra').gen_highlighter.words
    local hipat = require('mini.hipatterns')
    hipat.setup({
        highlighters = {
            hex_color = hipat.gen_highlighter.hex_color(),
            fixme = hi_words({ 'FIXME', 'Fixme', 'fixme', }, 'MiniHipatternsFixme'),
            xxx   = hi_words({ 'XXX', 'xxx' }, 'MiniHipatternsFixme'),
            todo  = hi_words({ 'TODO', 'Todo', 'todo' }, 'MiniHipatternsTodo'),
            hack  = hi_words({ 'HACK', 'Hack', 'hack' }, 'MiniHipatternsHack'),
            note  = hi_words({ 'NOTE', 'Note', 'note' }, 'MiniHipatternsNote'),
       },
    })

    ---------------------------------------------------------------------
    -- mini.pick --------------------------------------------------------
    ---------------------------------------------------------------------

    local win_config = function()
        local height = math.floor(0.6 * vim.o.lines)
        local width = 82 -- math.floor(0.6 * vim.o.columns)
        return {
            anchor = 'NW',
            height = height,
            width = width,
            row = math.floor(0.5 * (vim.o.lines - height)),
            col = math.floor(0.5 * (vim.o.columns - width)),
        }
    end

    local pick = require('mini.pick')
    pick.setup({
        mappings = {
            move_down         = '<C-j>',
            move_up           = '<C-k>',
            scroll_down       = '<C-d>',
            scroll_up         = '<C-u>',
            choose_in_split   = '<C-x>',
            choose_in_vsplit  = '<C-v>',
            choose_in_tabpage = '<C-t>',
            mark              = '<C-r>',
            choose_marked     = '<C-q>',
            paste             = '',
            location_list     = {
                char = '<C-l>',
                func = function()
                    local picks = pick.get_picker_matches()
                    if picks and picks.all then
                        pick.default_choose_marked(picks.all,
                                                   { list_type = 'location' })
                    end
                    return true
                end,
            },
        },
        window = {
            config = win_config,
        },
        source = {
            choose_marked = function(items)
                pick.default_choose_marked(items,
                                           { list_type = 'location' })
            end
        },
    })

    -- turn off the signcolumn for the mini.pick floating window
    -- vim.api.nvim_create_autocmd('User', {
    --     pattern = 'MiniPickStart',
    --     callback = function()
    --         vim.opt.signcolumn = 'no'
    --     end,
    -- })

    pick.registry.buffers_with_delete = function()
        return pick.builtin.buffers(
            { },
            {
                mappings = {
                    wipeout = {
                        char = '<C-b>',
                        func = function()
                            local bufnr =
                                pick.get_picker_matches().current.bufnr

                            if not vim.api.nvim_buf_is_valid(bufnr) then
                                return
                            end

                            vim.api.nvim_buf_delete(bufnr, {})
                        end,
                    },
                },
            })
    end

    -- Add a 'neovim_config' picker to access the Neovim configuration
    pick.registry.neovim_config = function()
        return pick.builtin.cli(
            {
                command = {
                    'rg',
                    '--follow', -- have to follow symlinks
                    '--files',
                    '--color=never',
                },
            },
            {
                source = {
                    name = 'neovim_config',
                    cwd = vim.fn.stdpath 'config',
                    show = function(buf_id, items, query)
                        return pick.default_show(buf_id, items, query,
                                                 { show_icons = true })
                    end,
                },
            })
    end

    -- Add a 'registry' picker that lists all the available pickers
    pick.registry.registry = function()
        local items = vim.tbl_keys(pick.registry)
        table.sort(items)
        local chosen_picker_name = pick.start({
            source = {
                items = items,
                name = 'Registry',
                choose = function() end
            },
        })
        if chosen_picker_name == nil then return end
        return pick.registry[chosen_picker_name]()
    end

    vim.ui.select = pick.ui_select

    ---------------------------------------------------------------------
    -- mini.clue --------------------------------------------------------
    ---------------------------------------------------------------------

    require('mini.clue').setup({
        window = {
            delay = 500,
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
            { mode = 'n', keys = '<leader>h',  desc = '+Git' },
            { mode = 'n', keys = '<leader>l',  desc = '+LSP' },
            { mode = 'n', keys = '<leader>o',  desc = '+Session' },
            { mode = 'n', keys = '<leader>q',  desc = '+Quickfix' },
            { mode = 'n', keys = '<leader>s',  desc = '+Search' },
            { mode = 'n', keys = '<leader>t',  desc = '+Tab' },
            { mode = 'n', keys = '<leader>j',  desc = '+Journal' },
            { mode = 'n', keys = '<leader>jd', desc = '+Journal Day' },
            { mode = 'n', keys = '<leader>jw', desc = '+Journal Week' },
            { mode = 'n', keys = '<leader>m',  desc = '+Markdown' },
            { mode = 'n', keys = '<leader>mt', desc = '+Tag' },
            { mode = 'n', keys = '<leader>n',  desc = '+Notes' },
            { mode = 'n', keys = '<leader>nt', desc = '+Tasks' },
            { mode = 'n', keys = '<leader>nr', desc = '+Read' },
        },
    })

    ---------------------------------------------------------------------
    -- MISC -------------------------------------------------------------
    ---------------------------------------------------------------------

    -- HACK: mini.tabline
    -- Doesn't support tabs, just a dumb buffer list.

    -- HACK: mini.statusline
    -- Can't easily change separators to nerdfont glyphs.

    -- HACK: mini.notify
    -- It does not get all messages directed to it. Noice is required to
    -- do all the redirecting of messages. Noice+mini backend is great!

    -- HACK: mini.completion
    -- I don't have high hopes for this vs blink.

    -- HACK: mini.files
    -- I like oil better along with mini.pick pickers
end

return M
