
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

vim.opt.splitright = false
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
vim.keymap.set('n', '<leader>tn', '<cmd>tabnew<CR>',      { desc = 'Tab new' })
vim.keymap.set('n', '<leader>th', '<cmd>tabprevious<CR>', { desc = 'Tab previous' })
vim.keymap.set('n', '<leader>tl', '<cmd>tabnext<CR>',     { desc = 'Tab next' })
vim.keymap.set('n', '<leader>tH', '<cmd>tabmove -1<CR>',  { desc = 'Tab move before' })
vim.keymap.set('n', '<leader>tL', '<cmd>tabmove +1<CR>',  { desc = 'Tab move after' })
for i = 1, 9, 1 do
  vim.keymap.set('n', '<leader>t' .. i, i .. 'gt', { desc = 'Tab goto ' .. i })
end

-- telescope for marks
vim.keymap.set('n', '<leader>sm', require('telescope.builtin').marks, { desc = '[S]earch [M]arks' })

-- telescope for marks.nvim marks/bookmarks
--vim.keymap.set('n', '<leader>mm', '<cmd>MarksListAll<CR><cmd>lcl<CR><cmd>Telescope loclist<CR>', { silent = true, desc = '[M]arks [M]arks' })
--vim.keymap.set('n', '<leader>mb', '<cmd>BookmarksListAll<CR><cmd>lcl<CR><cmd>Telescope loclist<CR>', { silent = true, desc = '[M]arks [B]ookmarks' })

-- marks.nvim keymaps and commands for quickfix split at bottom and full width
require('which-key').register({ ['<leader>m'] = { name = '[M]arks', _ = 'which_key_ignore' } })
vim.keymap.set('n', '<leader>mf', '<cmd>MarksListBuf<CR>', { silent = true, desc = '[M]arks Bu[f]fer' })
vim.keymap.set('n', '<leader>mm', '<cmd>MarksListAll<CR>', { silent = true, desc = '[M]arks [M]arks all' })
vim.keymap.set('n', '<leader>mb', '<cmd>BookmarksListAll<CR>', { silent = true, desc = '[M]arks [B]ookmarks all' })
vim.cmd([[
command! MQFListAll  exe "lua require('marks').mark_state:all_to_list('quickfixlist')" | botright copen
command! BMQFListAll exe "lua require('marks').bookmark_state:all_to_list('quickfixlist')" | botright copen
]])

-- quickfix/location list window stuff
vim.keymap.del('n', '<leader>q')
require('which-key').register({ ['<leader>q'] = { name = '[Q]uickfix', _ = 'which_key_ignore' } })
vim.keymap.set('n', '<leader>qo', '<cmd>lopen<CR>', { silent = true, desc = '[Q]uickfix [O]open' })
--vim.keymap.set('n', '<leader>qc', '<cmd>windo if &buftype == "quickfix" || &buftype == "locationlist" | lclose | endif<CR>', { silent = true, desc = '[Q]uickfix [C]lose' })
vim.keymap.set('n', '<leader>qc', '<cmd>lclose<CR>', { silent = true, desc = '[Q]uickfix [C]lose' })
vim.keymap.set('n', '<leader>qx', '<cmd>lexpr []<CR>', { silent = true, desc = '[Q]uickfix [X]clear' })

-- obsidian
require('which-key').register({ ['<leader>o'] = { name = '[O]bsidian', _ = 'which_key_ignore' } })
vim.keymap.set('n', '<leader>oq', '<cmd>ObsidianQuickSwitch<CR>', { desc = '[O]bsidian [Q]uickSwitch' })
vim.keymap.set('n', '<leader>os', '<cmd>ObsidianSearch<CR>', { desc = '[O]bsidian [S]earch' })
vim.keymap.set('n', '<leader>ot', '<cmd>ObsidianToday<CR>', { desc = '[O]bsidian [T]oday' })
vim.keymap.set('n', '<leader>oj', '<cmd>ObsidianDailies -30 1<CR>', { desc = '[O]bsidian [J]ournal' })
vim.keymap.set('n', '<leader>ob', '<cmd>ObsidianBacklinks<CR>', { desc = '[O]bsidian [B]acklinks' })
vim.keymap.set('n', '<leader>of', '<cmd>ObsidianLinks<CR>', { desc = '[O]bsidian [F]orward links' })

-- all comments rendered in italics
vim.cmd.hi 'Comment gui=none cterm=italic gui=italic'

-- virtual text (for search) needs to stand out more
vim.cmd.hi 'link NoiceVirtualText BufferAlternateERROR'

-- tabline text needs to stand out more
vim.cmd.hi 'TabLine guifg=#e0af68'

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
