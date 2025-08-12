return {
    'HakonHarnes/img-clip.nvim',
    event = 'VeryLazy',
    opts = {
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
    },
    keys = {
        { '<Leader>p', '<Cmd>PasteImage<CR>', desc = 'Paste image from system clipboard' },
    },
}
