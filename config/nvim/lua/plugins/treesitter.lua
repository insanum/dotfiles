return {
    'nvim-treesitter/nvim-treesitter',
    enabled = true,
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs',
    opts = {
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
            'python'
        },
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = false }, -- This completely F's cinoptions...
    },
}
