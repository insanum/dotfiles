
vim.opt.relativenumber = true
vim.opt.mouse = ''
vim.opt.clipboard = ''

vim.opt.list = false
vim.opt.listchars = { tab = '«·»', trail = '·', nbsp = '␣' }

vim.opt.colorcolumn = '80'
vim.opt.showtabline = 2

vim.opt.winheight = 10
vim.opt.winminheight = 10
vim.opt.winwidth = 10
vim.opt.winminwidth = 10

vim.opt.splitright = true
vim.opt.splitbelow = false

-- I like cinoptions! (vs an annoying autoformatter plugin)...
vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufReadPost' }, {
  pattern = { '*.c', '*.h', '*.cc', '*.cpp', '*.ino', '*.cs', '*.java', '*.js', '*.lua', '*.rs' },
  callback = function()
    vim.opt.cindent = true
    vim.opt.cinoptions = 's,e0,n0,f0,{0,}0,^0,:0,=s,gs,hs,ps,t0,+s,c1,(0,us,)20,*30,Ws'
  end
})

-- toggle list chars
vim.keymap.set('n', ',l', '<cmd>set list!<CR><cmd>set list?<CR>', { desc = 'Toggle listchars' })

-- remove highlighted search results
vim.keymap.del('n', '<Esc>')
vim.keymap.set('n', ',.', '<cmd>nohlsearch<CR>', { desc = 'Remove highlighted search results' })

-- remapping Y was a stupid change by neovim
vim.keymap.set('n', 'Y', 'yy')

-- jump/edit the previous buffer
vim.keymap.set('n', '<C-b>', '<cmd>e #<CR>')

-- I smash <C-s> all the time!
vim.keymap.set('n', '<C-s>', '<cmd>update<CR>', { silent = true, noremap = true })
vim.keymap.set('i', '<C-s>', '<C-o><cmd>update<CR>', { silent = true, noremap = true })

-- zoom the current window in/out
vim.keymap.set('n', 'Zi', '<C-w>_ | <C-w>|', { silent = true, noremap = true, desc = 'Zoom window in' })
vim.keymap.set('n', 'Zo', '<C-w>=', { silent = true, noremap = true, desc = 'Zoom window out' })

-- toggle spelling
vim.keymap.set('n', ',s', '<cmd>set spell!<CR><cmd>set spell?<CR>', { silent = true, desc = 'Toggle spelling' })

-- toggle paste
vim.keymap.set('n', ',v', '<cmd>set paste!<CR><cmd>set paste?<CR>', { silent = true, desc = 'Toggle paste' })

-- cut/paste to/from system clipboard
vim.keymap.set('v', ',y', '+y',  { silent = true, desc = 'Yank multiple lines (clipboard)' })
vim.keymap.set('n', ',y', '+y',  { silent = true, desc = 'Yank motion (clipboard)' })
vim.keymap.set('n', ',Y', '+yy', { silent = true, desc = 'Yank single line (clipboard)' })
vim.keymap.set('v', ',p', '+p',  { silent = true, desc = 'Paste overwrite lines (clipboard)' })
vim.keymap.set('n', ',P', '+P',  { silent = true, desc = 'Paste before cursor (clipboard)' })
vim.keymap.set('n', ',p', '+p',  { silent = true, desc = 'Paste after cursor (clipboard)' })

-- tab stuff
vim.keymap.set('n', 'tn', '<cmd>tabnew<CR>',      { desc = 'Tab new' })
vim.keymap.set('n', 'th', '<cmd>tabprevious<CR>', { desc = 'Tab previous' })
vim.keymap.set('n', 'tl', '<cmd>tabnext<CR>',     { desc = 'Tab next' })
vim.keymap.set('n', 'tH', '<cmd>tabmove -1<CR>',  { desc = 'Tab move before' })
vim.keymap.set('n', 'tL', '<cmd>tabmove +1<CR>',  { desc = 'Tab move after' })
for i = 1, 9, 1 do
  vim.keymap.set('n', ',' .. i, i .. 'gt', { desc = 'Tab goto ' .. i })
end

-- telescope for marks
vim.keymap.set('n', '<leader>sm', require('telescope.builtin').marks, { desc = '[S]earch [M]arks' })

-- telescope for bookmarks
vim.keymap.set('n', '<leader>b', '<cmd>BookmarksListAll<CR><cmd>lcl<CR><cmd>Telescope loclist<CR>', { silent = true, desc = '[B]ookmarks' })

-- all comments rendered in italics
vim.cmd.hi 'Comment gui=none cterm=italic gui=italic'

-- virtual text (for search) needs to stand out a bit more
vim.cmd.hi 'link NoiceVirtualText DiagnosticVirtualTextError'

-- Workaround for bug where Telescope enters Insert mode on selection:
-- https://github.com/nvim-telescope/telescope.nvim/issues/2027
vim.api.nvim_create_autocmd('WinLeave', {
  callback = function()
    if vim.bo.ft == 'TelescopePrompt' and vim.fn.mode() == 'i' then
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'i', false)
    end
  end,
})

-- vim: ts=2 sts=2 sw=2 et
