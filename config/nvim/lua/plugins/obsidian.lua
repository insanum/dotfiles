return {
    'epwalsh/obsidian.nvim',
    dependencies = {
        'nvim-lua/plenary.nvim',
        'nvim-treesitter/nvim-treesitter',
        'nvim-telescope/telescope.nvim',
    },
    opts = {
        dir = '/Volumes/work/notes',
        daily_notes = {
            folder = 'Journal',
            date_format = '%Y-%m-%d',
        },
        --disable_frontmatter = true,
        note_id_func = function(title)
            if title ~= nil then
                return title
            end
            return tostring(os.time())
        end,
        picker = {
            name = "telescope.nvim"
        },
        ui = {
            enable = false,
        },
    },
    keys = {
      { '<leader>oo', '<cmd>tabnew<CR><cmd>tcd /Volumes/work/notes<CR><cmd>setlocal conceallevel=1<CR><cmd>ObsidianQuickSwitch<CR>', desc = '[O]bsidian [O]pen' },
    },
}
