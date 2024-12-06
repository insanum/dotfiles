return {
    'epwalsh/obsidian.nvim',
    dependencies = {
        'nvim-lua/plenary.nvim',
        'nvim-treesitter/nvim-treesitter',
        --'nvim-telescope/telescope.nvim',
        'echasnovski/mini.pick',
    },
    opts = {
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
    },
    keys = {
        {
            '<leader>oo',
            '<cmd>tabnew<CR><cmd>tcd /Volumes/work/notes<CR><cmd>setlocal conceallevel=1<CR><cmd>ObsidianQuickSwitch<CR>',
            desc = '[O]bsidian [O]pen'
        },
    },
}
