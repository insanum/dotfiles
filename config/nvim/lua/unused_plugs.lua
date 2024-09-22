
return {

  {
    'tpope/vim-fugitive',
    enabled = false,
    event = 'VeryLazy',
  },

  {
    'stevearc/aerial.nvim',
    enabled = false,
    event = 'VeryLazy',
    opts = {},
    dependencies = {
        'nvim-treesitter/nvim-treesitter',
        'nvim-tree/nvim-web-devicons'
    },
  },

  {
    'TabbyML/vim-tabby',
    config = function()
        vim.g.tabby_node_binary = '/opt/homebrew/bin/node'
        vim.g.tabby_keybinding_accept = '<C-f>'
        vim.g.tabby_trigger_mode = 'auto'
    end,
  },

  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    opts = {},
  },

  {
    'junegunn/vim-easy-align',
    config = function()
        vim.keymap.set('x', 'ga', '<Plug>(EasyAlign)')
        --vim.keymap.set('n', 'ga', '<Plug>(EasyAlign)')
    end,
  },

  {
    'numToStr/FTerm.nvim',
    config = function()
        require'FTerm'.setup({
            --env = { TERM = 'tmux-256color' },
            border = 'double',
            dimensions  = {
                height = 0.8,
                width = 0.8,
            },
        })
    end,
  },

  {
    'navarasu/onedark.nvim',
    lazy = false,
    priority = 999,
    config = function()
        vim.cmd.colorscheme 'onedark'
    end,
  },

  {
    'rmehri01/onenord.nvim',
    lazy = false,
    priority = 999,
    config = function()
        vim.cmd.colorscheme 'onenord'
    end,
  },

  {
    'ellisonleao/gruvbox.nvim',
    lazy = false,
    priority = 999,
    config = function()
        vim.opt.background = 'dark'
        vim.cmd.colorscheme 'gruvbox'
    end,
  },

}

