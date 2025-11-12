local M = {}

M.setup = function(add)
    add({
        source = 'nvim-treesitter/nvim-treesitter',
        checkout = 'master',
        monitor = 'main',
        hooks = { post_checkout = function() vim.cmd('TSUpdate') end },
    })

    require('nvim-treesitter.configs').setup({
        ensure_installed = {
            'bash',
            'c',
            'html',
            'lua',
            'markdown',
            'markdown_inline',
            'vim',
            'vimdoc',
            'javascript',
            'rust',
            'python',
            'zig',
        },
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = false }, -- This completely F's cinoptions...
    })

end

return M
