return {
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    branch = '0.1.x',
    dependencies = {
        'nvim-lua/plenary.nvim',
        { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make', },
        'nvim-telescope/telescope-ui-select.nvim',
        'nvim-tree/nvim-web-devicons',
    },
    config = function()
        -- Important keymaps to use while in Telescope are:
        --  - Insert mode: <c-/>
        --  - Normal mode: ?

        local actions = require("telescope.actions")
        local select_map = {
            i = { ['<C-j>'] = actions.move_selection_next,
                  ['<C-k>'] = actions.move_selection_previous, },
            n = { ['<C-j>'] = actions.move_selection_next,
                  ['<C-k>'] = actions.move_selection_previous, },
        }
        --local tab_drop_map = {
        --  i = { ['<CR>'] = actions.select_tab_drop },
        --  n = { ['<CR>'] = actions.select_tab_drop },
        --}
        require('telescope').setup {
          -- You can put your default mappings / updates / etc. in here
          --  All the info you're looking for is in `:help telescope.setup()`
          defaults = {
              mappings = select_map,
              vimgrep_arguments = {
                  "rg",
                  "--color=never",
                  "--no-heading",
                  "--with-filename",
                  "--line-number",
                  "--column",
                  "--smart-case",
                  "--follow",
              },
          },
          pickers = {
              buffers = {
                  sort_mru = true,
              },
              -- buffers    = { mappings = tab_drop_map, },
              -- quickfix   = { mappings = tab_drop_map, },
              -- marks      = { mappings = tab_drop_map, },
              -- find_files = { mappings = tab_drop_map, },
          },
          extensions = {
              ['ui-select'] = {
                  require('telescope.themes').get_dropdown(),
              },
          },
      }

      -- enable Telescope extensions which should be installed by default
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
      vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

      vim.keymap.set('n', '<leader>sf',
          function()
              builtin.find_files({ follow = true })
          end,
          { desc = '[S]earch [F]iles' })

      vim.keymap.set('n', '<leader>/',
          function()
              local drop_theme = require('telescope.themes').get_dropdown({ winblend = 10, previewer = false })
              builtin.current_buffer_fuzzy_find(drop_theme)
          end,
          { desc = '[/] Fuzzily search in current buffer' })

      vim.keymap.set('n', '<leader>s/',
          function()
              builtin.live_grep({ grep_open_files = true, prompt_title = 'Live Grep in Open Files' })
          end,
          { desc = '[S]earch [/] in Open Files' })

      -- Shortcut for searching your Neovim configuration files
      vim.keymap.set('n', '<leader>sn',
          function()
              builtin.find_files({ follow = true, cwd = vim.fn.stdpath 'config' })
          end,
          { desc = '[S]earch [N]eovim files' })
    end,
}
