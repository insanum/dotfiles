return {
    'j-morano/buffer_manager.nvim',
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
}
