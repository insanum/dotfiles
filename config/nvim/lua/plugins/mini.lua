return {
    'echasnovski/mini.nvim',
    config = function()
        -- Better Around/Inside textobjects
        -- Examples:
        --  - va)  - [V]isually select [A]round [)]paren
        --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
        --  - ci'  - [C]hange [I]nside [']quote
        require('mini.ai').setup { n_lines = 500 }

        -- Add/delete/replace surroundings (brackets, quotes, etc.)
        -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
        -- - sd'   - [S]urround [D]elete [']quotes
        -- - sr)'  - [S]urround [R]eplace [)] [']
        require('mini.surround').setup()

        require('mini.align').setup()

        require('mini.trailspace').setup()

        require('mini.comment').setup()

        local indentscope = require('mini.indentscope')
        indentscope.setup({
            symbol='│',
            draw = {
                animation = indentscope.gen_animation.none(),
                --animation = indentscope.gen_animation.quadratic({ easing = 'out', duration = 10, unit = 'total' }),
            },
        })

        require('mini.files').setup({
            windows = {
                preview = true, -- show preview of file/directory under cursor
                width_focus = 40,
                width_nofocus = 40,
                width_preview = 40,
            },
        })

        vim.keymap.set('n', '<F12>', '<cmd>lua MiniFiles.open()<CR>', { desc = 'Mini Files', })
    end,
}
