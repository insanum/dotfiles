local M = {}

M.setup = function(add)
    add({
        source = 'stevearc/oil.nvim',
        depends = {
            'nvim-tree/nvim-web-devicons',
        },
    })

    require('oil').setup({
        default_file_explorer = true,
        skip_confirm_for_simple_edits = false,
        columns = {
            'icon',
            'size',
            'mtime',
        },
        view_options = {
            show_hidden = true,
        },
        float = {
            padding = 4,
            border = 'rounded',
            preview_split = 'right',
        },
        keymaps = {
            ['<C-v>'] = { 'actions.select', opts = { vertical = true } },
            ['<C-x>'] = { 'actions.select', opts = { horizontal = true } },
        },
    })

    vim.keymap.set('n', '<leader>O',
                   '<cmd>Oil --float --preview<CR>',
                   { desc = 'Oil', })
end

return M
