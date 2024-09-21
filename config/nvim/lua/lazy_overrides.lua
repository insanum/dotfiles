
-- Return a table that gets merged into the plugin config spec table...

return {

  { -- override nvim-treesitter
    -- I added this override just to be able to get to 'indent'. I don't
    -- think the plugin spec by kickstart is implemented correctly. Funny,
    -- I came up with the same exact solution as this dude...
    -- https://github.com/nvim-lua/kickstart.nvim/pull/732
    'nvim-treesitter/nvim-treesitter',
    opts = {
      ensure_installed = {
        'bash', 'c', 'html', 'lua', 'markdown', 'markdown_inline',
        'vim', 'vimdoc', 'javascript', 'rust', 'python'
      },
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = false }, -- This completely F's cinoptions...
    },
    config = function(_, opts)
      require('nvim-treesitter.configs').setup(opts)
    end,
  },

  { -- override mini.nvim
    'echasnovski/mini.nvim',
    config = function()
      require('mini.ai').setup { n_lines = 500 }
      --require('mini.surround').setup()
      --require('mini.align').setup()
      require('mini.trailspace').setup()
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
          -- Whether to show preview of file/directory under cursor
          preview = true,
          width_focus = 40,
          width_nofocus = 40,
          width_preview = 40,
        },
      })
      vim.keymap.set('n', '<F12>', '<cmd>lua MiniFiles.open()<CR>', { desc = 'Mini Files', })
    end,
  },

  { -- override gitsigns.nvim
    'lewis6991/gitsigns.nvim',
    opts = {
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map({ 'n', 'v' }, ']c', function()
          if vim.wo.diff then
            return ']c'
          end
          vim.schedule(function()
            gs.next_hunk()
          end)
          return '<Ignore>'
        end, { expr = true, desc = 'Jump to next hunk' })

        map({ 'n', 'v' }, '[c', function()
          if vim.wo.diff then
            return '[c'
          end
          vim.schedule(function()
            gs.prev_hunk()
          end)
          return '<Ignore>'
        end, { expr = true, desc = 'Jump to previous hunk' })

        -- Actions
        -- visual mode
        map('v', '<leader>hs', function()
          gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
        end, { desc = 'stage git hunk' })
        map('v', '<leader>hr', function()
          gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
        end, { desc = 'reset git hunk' })
        -- normal mode
        map('n', '<leader>hs', gs.stage_hunk, { desc = 'git Stage hunk' })
        map('n', '<leader>hr', gs.reset_hunk, { desc = 'git Reset hunk' })
        map('n', '<leader>hS', gs.stage_buffer, { desc = 'git Stage buffer' })
        map('n', '<leader>hu', gs.undo_stage_hunk, { desc = 'git Undo stage hunk' })
        map('n', '<leader>hR', gs.reset_buffer, { desc = 'git Reset buffer' })
        map('n', '<leader>hp', gs.preview_hunk, { desc = 'git Preview hunk' })
        map('n', '<leader>hb', function()
          gs.blame_line({ full = false })
        end, { desc = 'git Blame line' })
        map('n', '<leader>hd', gs.diffthis, { desc = 'git Diff against index' })
        --map('n', '<leader>hD', function()
        --  gs.diffthis('~')
        --end, { desc = 'git Diff against last commit' })

        -- Toggles
        --map('n', '<leader>hB', gs.toggle_current_line_blame, { desc = 'toggle git blame line' })
        --map('n', '<leader>hL', gs.toggle_deleted, { desc = 'toggle git show deleted' })

        -- Text object
        map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'git Select hunk' })
      end,
    },
  },

  {
    'max397574/better-escape.nvim',
    config = function()
      require('better_escape').setup() -- 'jj' or 'jk' = <ESC>
    end,
  },

  {
    'NvChad/nvim-colorizer.lua',
    main = 'colorizer',
    opts = {},
  },

  --[[
  {
    'tpope/vim-fugitive',
    enabled = false,
    event = 'VeryLazy',
  },
  --]]

  {
    'NeogitOrg/neogit',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'sindrets/diffview.nvim',
      'nvim-telescope/telescope.nvim',
    },
    config = true,
    keys = {
      { '<leader>hg', '<cmd>Neogit<CR>', desc = 'git Neogit' },
    },
  },

  {
    'ThePrimeagen/git-worktree.nvim',
    event = 'VeryLazy',
    config = function()
      --vim.g.git_worktree_log_level = 'debug'
      require('git-worktree').setup({
        change_directory_command = 'tcd',
        update_on_change_command = 'Telescope find_files',
        --autopush = true,
      })
      require('telescope').load_extension('git_worktree')
      vim.keymap.set('n', '<leader>hw', '<cmd>Telescope git_worktree<CR>', { desc = 'git Worktree switch' })
      vim.keymap.set('n', '<leader>hW', require('telescope').extensions.git_worktree.create_git_worktree, { desc = 'git Worktree create' })
    end,
  },

  --[[
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
  --]]

  {
    'jedrzejboczar/possession.nvim',
    opts = {
      commands = {
        save = 'PoSave',
        load = 'PoLoad',
        close = 'PoClose',
        delete = 'PoDelete',
        show = 'PoShow',
        list = 'PoList',
        migrate = 'PoMigrate',
      },
    },
    keys = {
      { ',o', '<cmd>Telescope possession list<CR>', desc = 'Possession' },
    },
    config = function(_, opts)
      require('possession').setup(opts)
      require('telescope').load_extension('possession')
    end,
  },

  {
    'nvim-lualine/lualine.nvim',
    event = 'VimEnter',
    config = function()
      local function show_codeium_status()
        return '{…}' .. vim.fn['codeium#GetStatusString']()
      end

      require('lualine').setup({
        options = {
          theme = 'tokyonight',
        },
        sections = {
          lualine_b = {
            { show_codeium_status },
            { 'branch' },
            { 'diff', colored = false },
            { 'diagnostics' },
          },
          lualine_c = {
            {
              -- with lots of splits, make sure the filenames stand out
              'filename',
              color = { fg = '#15161e', bg = '#ff9e64' },
            },
          },
        },
        inactive_sections = {
          lualine_c = {
            {
              -- with lots of splits, make sure the filenames stand out
              'filename',
              color = { fg = '#15161e', bg = '#f7768e' },
            },
          },
        },
      })
    end,
  },

  {
    'nanozuki/tabby.nvim',
    event = 'VimEnter',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },
    opts = {},
  },

  {
    'kevinhwang91/nvim-bqf',
    event = 'VeryLazy',
    opts = {}
  },

  {
    'chentoast/marks.nvim',
    event = 'VeryLazy',
    config = function()
      require('marks').setup {
        --builtin_marks = { '.', '<', '>', '^' },
        --sign_priority = { lower=10, upper=15, builtin=8, bookmark=20 },
      }
    end,
  },

  {
    'j-morano/buffer_manager.nvim',
    event = 'VeryLazy',
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    opts = {
      select_menu_item_commands = {
        edit = {
          key = '<CR>',
          command = 'edit'
        },
        v = {
          key = '<C-v>',
          command = 'vsplit'
        },
        h = {
          key = '<C-x>',
          command = 'split'
        }
      },
    },
    config = function(_, opts)
      require('buffer_manager').setup(opts)
      local bm_ui = require('buffer_manager.ui')
      local keys = '1234567890'

      vim.keymap.set('n', ';', bm_ui.toggle_quick_menu, { desc = 'Buffer Manager' })

      for i = 1, #keys do
        local key = keys:sub(i,i)
        vim.keymap.set('n', string.format('<leader>%s', key), function () bm_ui.nav_file(i) end, { desc = string.format('Buffer Manager: Goto buffer %s', key) })
      end
    end,
  },

  {
    'ggandor/leap.nvim',
    keys = {
      { 's', '<Plug>(leap-forward)', desc = 'Leap forward' },
      { 'S', '<Plug>(leap-backward)', desc = 'Leap backward' },
    },
  },

  {
    -- Note: 'Exafunction/codeium.nvim' (note n) doesn't support ghost text!
    'Exafunction/codeium.vim',
    enabled = true,
    event = 'BufEnter',
    config = function()
      -- force codeium to use socks5 proxy
      vim.env.HTTP_PROXY = 'socks5://127.0.0.1:9999'
      vim.env.HTTPS_PROXY = 'socks5://127.0.0.1:9999'

      vim.g.codeium_idle_delay = 75
      vim.keymap.set('i', '<C-f>', function()
        return vim.fn['codeium#CycleCompletions'](1)
      end, { expr = true, silent = true })
      vim.keymap.set('i', '<C-g>', function()
        return vim.fn['codeium#CycleCompletions'](-1)
      end, { expr = true, silent = true })
    end,
  },

  --[[
  {
    'TabbyML/vim-tabby',
    config = function()
      vim.g.tabby_node_binary = '/opt/homebrew/bin/node'
      vim.g.tabby_keybinding_accept = '<C-f>'
      vim.g.tabby_trigger_mode = 'auto'
    end,
  },
  --]]

  --[[
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    opts = {},
  },
  --]]

  {
    'junegunn/vim-easy-align',
    config = function()
      vim.keymap.set('x', 'ga', '<Plug>(EasyAlign)')
      --vim.keymap.set('n', 'ga', '<Plug>(EasyAlign)')
    end,
  },

  {
    'folke/noice.nvim',
    event = 'VeryLazy',
    opts = {},
    dependencies = {
      'MunifTanjim/nui.nvim',
      {
        'rcarriga/nvim-notify',
        opts = {
          render = 'default',
          stages = 'static',
          top_down = false;
        },
      },
    },
  },

  --[[
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
  --]]

  --[[
  {
    'navarasu/onedark.nvim',
    lazy = false,
    priority = 999,
    config = function()
      vim.cmd.colorscheme 'onedark'
    end,
  },
  --]]

  --[[
  {
    'rmehri01/onenord.nvim',
    lazy = false,
    priority = 999,
    config = function()
      vim.cmd.colorscheme 'onenord'
    end,
  },
  --]]

  --[[
  {
    'ellisonleao/gruvbox.nvim',
    lazy = false,
    priority = 999,
    config = function()
      vim.opt.background = 'dark'
      vim.cmd.colorscheme 'gruvbox'
    end,
  },
  --]]

  {
    'epwalsh/obsidian.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
      'nvim-telescope/telescope.nvim',
    },
    opts = {
      dir = '/Volumes/work/notes',
      daily_notes = {
        folder = 'Journal',
        date_format = '%Y-%m-%d',
      },
      disable_frontmatter = true,
      note_id_func = function(title)
        if title ~= nil then
          return title
        end
        return tostring(os.time())
      end,
      picker = { name = "telescope.nvim" },
    },
    keys = {
      { '<leader>oo', '<cmd>tabnew<CR><cmd>tcd /Volumes/work/notes<CR><cmd>setlocal conceallevel=1<CR><cmd>ObsidianQuickSwitch<CR>', desc = '[O]bsidian [O]pen' },
    },
  },
}

