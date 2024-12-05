
-- make split navigation easier
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- I like cinoptions! (vs an annoying autoformatting plugins)...
vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufReadPost' }, {
    pattern = { '*.c', '*.h', '*.cc', '*.cpp', '*.ino', '*.cs', '*.java', '*.js', '*.lua', '*.rs' },
    callback = function()
        vim.opt.cindent = true
        vim.opt.indentexpr = nil
        vim.opt.cinoptions = 's,e0,n0,f0,{0,}0,^0,:0,=s,gs,hs,ps,t0,+s,c1,(0,us,)20,*30,Ws'
    end
})

-- toggle list chars
vim.keymap.set('n', ',l', '<cmd>set list!<CR><cmd>set list?<CR>', { desc = 'Toggle listchars' })

-- remove highlighted search results
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
vim.keymap.set('v', ',y', '"+y',  { silent = true, desc = 'Yank multiple lines (clipboard)' })
vim.keymap.set('n', ',y', '"+y',  { silent = true, desc = 'Yank motion (clipboard)' })
vim.keymap.set('n', ',Y', '"+yy', { silent = true, desc = 'Yank single line (clipboard)' })
vim.keymap.set('v', ',p', '"+p',  { silent = true, desc = 'Paste overwrite lines (clipboard)' })
vim.keymap.set('n', ',P', '"+P',  { silent = true, desc = 'Paste before cursor (clipboard)' })
vim.keymap.set('n', ',p', '"+p',  { silent = true, desc = 'Paste after cursor (clipboard)' })

-- tab stuff
vim.keymap.set('n', '<leader>tn', '<cmd>tabnew<CR>',      { desc = 'Tab new', noremap = true })
vim.keymap.set('n', '<leader>th', '<cmd>tabprevious<CR>', { desc = 'Tab previous', noremap = true })
vim.keymap.set('n', '<leader>tl', '<cmd>tabnext<CR>',     { desc = 'Tab next', noremap = true })
vim.keymap.set('n', '<leader>tH', '<cmd>tabmove -1<CR>',  { desc = 'Tab move before', noremap = true })
vim.keymap.set('n', '<leader>tL', '<cmd>tabmove +1<CR>',  { desc = 'Tab move after', noremap = true })
for i = 1, 9, 1 do
  vim.keymap.set('n', '<leader>t' .. i, i .. 'gt', { desc = 'Tab goto ' .. i })
end

-- location list window management (open/close/clear)
vim.keymap.set('n', '<leader>qo', '<cmd>lopen<CR>', { silent = true, desc = '[Q]uickfix [O]pen' })
vim.keymap.set('n', '<leader>qc', '<cmd>lclose<CR>', { silent = true, desc = '[Q]uickfix [C]lose' })
vim.keymap.set('n', '<leader>qx', '<cmd>lexpr []<CR>', { silent = true, desc = '[Q]uickfix [X]clear' })
vim.keymap.set('n', '<leader>qd', vim.diagnostic.setloclist, { desc = '[Q]uickfix [D]iagnostic' })
-- diagnostic hover
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })

-- obsidian
vim.keymap.set('n', '<leader>oq', '<cmd>ObsidianQuickSwitch<CR>', { desc = '[O]bsidian [Q]uickSwitch' })
vim.keymap.set('n', '<leader>os', '<cmd>ObsidianSearch<CR>', { desc = '[O]bsidian [S]earch' })
vim.keymap.set('n', '<leader>ot', '<cmd>ObsidianToday<CR>', { desc = '[O]bsidian [T]oday' })
vim.keymap.set('n', '<leader>oj', '<cmd>ObsidianDailies -30 1<CR>', { desc = '[O]bsidian [J]ournal' })
vim.keymap.set('n', '<leader>ob', '<cmd>ObsidianBacklinks<CR>', { desc = '[O]bsidian [B]acklinks' })
vim.keymap.set('n', '<leader>of', '<cmd>ObsidianLinks<CR>', { desc = '[O]bsidian [F]orward links' })

-- all comments rendered in italics
vim.cmd.hi 'Comment gui=none cterm=italic gui=italic'

-- virtual text (for search) needs to stand out more
vim.cmd.hi 'link NoiceVirtualText IncSearch'

-- tabline text needs to stand out more
vim.cmd.hi 'TabLine guifg=#e0af68'

