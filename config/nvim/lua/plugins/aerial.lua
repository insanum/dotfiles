return {
  'stevearc/aerial.nvim',
  dependencies = {
     'nvim-treesitter/nvim-treesitter',
     'nvim-tree/nvim-web-devicons',
  },
  config = function()
      require('aerial').setup()
      vim.keymap.set('n', '{', '<cmd>AerialPrev<CR>')
      vim.keymap.set('n', '}', '<cmd>AerialNext<CR>')
      vim.keymap.set('n', '<leader>a', '<cmd>AerialToggle! right<CR>',
                     { desc = 'Toggle Aerial' })
  end,
}
