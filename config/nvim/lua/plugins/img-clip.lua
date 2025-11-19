local M = {
    name = 'img-clip',
    plug = {
        'https://github.com/HakonHarnes/img-clip.nvim',
    },
    priority = 90,
}

M.opts = {
    default = {
        dir_path = '/Volumes/work/notes/assets',
        relative_to_current_file = true,
    },
    filetypes = {
        markdown = {
            --template = '![$CURSOR]($FILE_PATH)',
            template = '![[$FILE_NAME]]',
        },
    },
}

M.post_setup = function()
    vim.keymap.set('n', '<leader>p', '<cmd>PasteImage<CR>',
                   { desc = 'Paste image from system clipboard' })
end

return M
