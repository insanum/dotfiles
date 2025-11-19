local M = {
    name = 'oil',
    plug = {
        'https://github.com/stevearc/oil.nvim',
    },
    depends = {
        'https://github.com/nvim-tree/nvim-web-devicons',
    },
    priority = 90,
}

M.opts = {
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
}

M.post_setup = function()
    vim.keymap.set('n', '<leader>O',
                   '<cmd>Oil --float --preview<CR>',
                   { desc = 'Oil', })
end

return M
