local M = {}

M.setup = function(add)
    add({
        source = 'HakonHarnes/img-clip.nvim',
    })

    require('img-clip').setup({
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
    })

    vim.keymap.set('n', '<leader>p', '<cmd>PasteImage<CR>',
                   { desc = 'Paste image from system clipboard' })
end

return M
