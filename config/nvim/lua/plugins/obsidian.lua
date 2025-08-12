return {
    'epwalsh/obsidian.nvim',
    enabled = false,
    dependencies = {
        'nvim-lua/plenary.nvim',
        'nvim-treesitter/nvim-treesitter',
        --'nvim-telescope/telescope.nvim',
        'echasnovski/mini.pick',
    },
    config = function()
        local opts = {
            dir = '/Volumes/work/notes',
            daily_notes = {
                folder = 'Journal',
                date_format = '%Y-%m-%d',
                default_tags = nil,
                template = 'new_note.md',
            },
            templates = {
                folder = 'templates_nvim',
                date_format = '%Y-%m-%d',
                time_format = '%H:%M',
            },
            disable_frontmatter = true,
            note_id_func = function(title)
                if title ~= nil then
                    return title
                end
                return tostring(os.time())
            end,
            picker = {
                name = 'mini.pick',
            },
            ui = {
                enable = false,
            },
        }

        require('obsidian').setup(opts)

        vim.keymap.set('n', '<leader>oq', '<cmd>ObsidianQuickSwitch<CR>',
                       { desc = '[O]bsidian [Q]uickSwitch' })
        vim.keymap.set('n', '<leader>os', '<cmd>ObsidianSearch<CR>',
                       { desc = '[O]bsidian [S]earch' })
        vim.keymap.set('n', '<leader>ot', '<cmd>ObsidianToday<CR>',
                       { desc = '[O]bsidian [T]oday' })
        vim.keymap.set('n', '<leader>oj', '<cmd>ObsidianDailies -30 1<CR>',
                       { desc = '[O]bsidian [J]ournal' })
        vim.keymap.set('n', '<leader>ob', '<cmd>ObsidianBacklinks<CR>',
                       { desc = '[O]bsidian [B]acklinks' })
        vim.keymap.set('n', '<leader>of', '<cmd>ObsidianLinks<CR>',
                       { desc = '[O]bsidian [F]orward links' })
    end,
    keys = {
        {
            '<leader>oo',
            '<cmd>tabnew<CR><cmd>tcd /Volumes/work/notes<CR><cmd>setlocal conceallevel=1<CR><cmd>ObsidianQuickSwitch<CR>',
            desc = '[O]bsidian [O]pen'
        },
    },
}
