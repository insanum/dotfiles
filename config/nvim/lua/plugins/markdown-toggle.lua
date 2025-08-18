return {
    'roodolv/markdown-toggle.nvim',
    config = function()
        local toggle = require('markdown-toggle')
        toggle.setup({
            use_default_keymaps = false,
            list_before_box = true,
        })

        local opts = {
            silent = true,
            noremap = true,
        }

        -- An alternate to these markdown-toggle macros is:
        --
        --     vim.opt.formatoptions:append('ro')
        --     vim.opt.comments = 'b:- [ ],b:-,b:>,b:|'
        --
        -- Unfortunately this Neovim solution doesn't work with ordered lists!
        -- The following macros behave well vs pure Neovim.

        vim.keymap.set('n', 'O', toggle.autolist_up, opts)
        vim.keymap.set('n', 'o', toggle.autolist_down, opts)
        vim.keymap.set('i', '<CR>', toggle.autolist_cr, opts)

        opts.expr = true -- dot repeat in normal mode

        opts.desc = '[M]arkdown [L]list'
        vim.keymap.set('n', '<leader>ml', toggle.list_dot, opts)

        opts.desc = '[M]arkdown [O]rdered'
        vim.keymap.set('n', '<leader>mo', toggle.olist_dot, opts)

        opts.desc = '[M]arkdown [C]heckbox'
        vim.keymap.set('n', '<leader>mc', toggle.checkbox_dot, opts)

        opts.desc = '[M]arkdown [Q]uote'
        vim.keymap.set('n', '<leader>mq', toggle.quote_dot, opts)

        opts.desc = '[M]arkdown [H]eading'
        vim.keymap.set('n', '<leader>mh', toggle.heading_dot, opts)

        opts.expr = false -- visual mode

        opts.desc = '[M]arkdown [L]list'
        vim.keymap.set('x', '<leader>ml', toggle.list, opts)

        opts.desc = '[M]arkdown [O]rdered'
        vim.keymap.set('x', '<leader>mo', toggle.olist, opts)

        opts.desc = '[M]arkdown [C]heckbox'
        vim.keymap.set('x', '<leader>mc', toggle.checkbox, opts)

        opts.desc = '[M]arkdown [Q]uote'
        vim.keymap.set('x', '<leader>mq', toggle.quote, opts)

        opts.desc = '[M]arkdown [H]eading'
        vim.keymap.set('x', '<leader>mh', toggle.heading, opts)
    end,
}
