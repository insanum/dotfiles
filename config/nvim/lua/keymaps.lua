-- cache for tracking all custom keymaps defined in this config
local custom_keymaps = {}

-- wrapper around vim.keymap.set that caches the keymap
local function kmap(mode, lhs, rhs, opts)
    vim.keymap.set(mode, lhs, rhs, opts)

    -- handle multiple modes
    local modes = ((type(mode) == 'table') and mode) or { mode }
    for _, m in ipairs(modes) do
        table.insert(custom_keymaps, {
            mode = m,
            lhs = lhs,
            desc = (opts and opts.desc) or '',
        })
    end
end

-- show all custom keymaps in a mini.pick window
kmap('n', '<leader>?', function()
    local pick = require('mini.pick')

    -- sort by mode, then by keymap
    local sorted = vim.deepcopy(custom_keymaps)
    table.sort(sorted, function(a, b)
        if a.mode == b.mode then
            return a.lhs < b.lhs
        end
        return a.mode < b.mode
    end)

    pick.start({
        source = {
            items = sorted,
            name = 'Custom Keymaps',
            show = function(buf_id, items, query)
                local display_items = {}
                for _, item in ipairs(items) do
                    -- strip the '[' and ']' chars from the description
                    local desc = item.desc:gsub('[%[%]]', '')
                    table.insert(display_items,
                                 string.format('[%s]  %-20s  %s',
                                               item.mode,
                                               item.lhs,
                                               desc))
                end
                return pick.default_show(buf_id, display_items, query,
                                         { show_icons = true })
            end,
            choose = function() end,
        },
    })
end, { desc = '[?] Show all custom keymaps' })

-- make [count]j [count]k register in the jump list
kmap({ 'n', 'x' }, 'j', function()
     return vim.v.count > 1 and 'm\'' .. vim.v.count .. 'j' or 'j'
end, { noremap = true, expr = true })
kmap({ 'n', 'x' }, 'k', function()
     return vim.v.count > 1 and 'm\'' .. vim.v.count .. 'k' or 'k'
end, { noremap = true, expr = true })

-- blow away current word and insert mode
kmap('n', '<C-c>', 'ciw')

-- move to beginning/end of line
kmap('n', 'H', '^')
kmap('n', 'L', '$')

-- move visual block up/down a line
kmap('x' , 'J', ':m \'>+1<CR>gv=gv')
kmap('x' , 'K', ':m \'<-2<CR>gv=gv')

-- make split navigation easier
local split_nav_maps = {
    { '<C-h>', '<C-w><C-h>', 'Move focus to the left window' },
    { '<C-l>', '<C-w><C-l>', 'Move focus to the right window' },
    { '<C-j>', '<C-w><C-j>', 'Move focus to the lower window' },
    { '<C-k>', '<C-w><C-k>', 'Move focus to the upper window' },
}
for _, m in ipairs(split_nav_maps) do
    kmap('n', m[1], m[2], { desc = m[3] })
end

-- toggle list chars
kmap('n', ',l', '<cmd>set list!<CR><cmd>set list?<CR>',
     { desc = 'Toggle listchars' })

-- remove highlighted search results
kmap('n', ',.', '<cmd>nohlsearch<CR>',
     { desc = 'Remove highlighted search results' })

-- remapping Y was a stupid change by neovim
kmap('n', 'Y', 'yy')

-- jump/edit the previous buffer
kmap('n', '<C-b>', '<cmd>e #<CR>')

-- I smash <C-s> all the time!
kmap('n', '<C-s>', '<cmd>update<CR>', { silent = true, noremap = true })
kmap('i', '<C-s>', '<C-o><cmd>update<CR>', { silent = true, noremap = true })

-- zoom the current window in/out
kmap('n', 'Zi', '<C-w>_ | <C-w>|',
     { silent = true, noremap = true, desc = 'Zoom window in' })
kmap('n', 'Zo', '<C-w>=',
     { silent = true, noremap = true, desc = 'Zoom window out' })

-- toggle spelling
kmap('n', ',s', '<cmd>set spell!<CR><cmd>set spell?<CR>',
     { silent = true, desc = 'Toggle spelling' })

-- toggle paste
kmap('n', ',v', '<cmd>set paste!<CR><cmd>set paste?<CR>',
     { silent = true, desc = 'Toggle paste' })

-- cut/paste to/from system clipboard
local clipboard_maps = {
    { 'v', ',y', '"+y',  'Yank multiple lines (clipboard)' },
    { 'n', ',y', '"+y',  'Yank motion (clipboard)' },
    { 'n', ',Y', '"+yy', 'Yank single line (clipboard)' },
    { 'v', ',p', '"+p',  'Paste overwrite lines (clipboard)' },
    { 'n', ',P', '"+P',  'Paste before cursor (clipboard)' },
    { 'n', ',p', '"+p',  'Paste after cursor (clipboard)' },
}
for _, m in ipairs(clipboard_maps) do
    kmap(m[1], m[2], m[3], { silent = true, desc = m[4] })
end

-- <leader>t<.> : tab stuff
local tab_maps = {
    { 'tn', 'tabnew',      'Tab new' },
    { 'th', 'tabprevious', 'Tab previous' },
    { 'tl', 'tabnext',     'Tab next' },
    { 'tH', 'tabmove -1',  'Tab move before' },
    { 'tL', 'tabmove +1',  'Tab move after' },
}
for _, m in ipairs(tab_maps) do
    kmap('n', '<leader>' .. m[1], '<cmd>' .. m[2] .. '<CR>',
         { noremap = true, desc = m[3] })
end

-- direct tab goto keymaps
for i = 1, 9 do
    kmap('n', '<leader>t' .. i, i .. 'gt', { desc = 'Tab goto ' .. i })
end

-- <leader>q<.> - location list helpers (open/close/clear/next/prev/etc)
local qf_maps = {
    { 'qo', 'lopen',    '[Q]uickfix [O]pen' },
    { 'qc', 'lclose',   '[Q]uickfix [C]lose' },
    { 'qn', 'lnext',    '[Q]uickfix [N]ext' },
    { 'qp', 'lprev',    '[Q]uickfix [P]revious' },
    { 'qf', 'lnfile',   '[Q]uickfix Next [F]ile' },
    { 'qF', 'lpfile',   '[Q]uickfix Previous [F]ile' },
    { 'qx', 'lexpr []', '[Q]uickfix [X]clear' },
}
for _, m in ipairs(qf_maps) do
    kmap('n', '<leader>' .. m[1], '<cmd>' .. m[2] .. '<CR>',
         { silent = true, desc = m[3] })
end

-- dump ALL diagnostics into the location list
kmap('n', '<leader>qd', vim.diagnostic.setloclist,
     { desc = '[Q]uickfix [D]iagnostic' })

-- diagnostic hover
kmap('n', '<leader>e', vim.diagnostic.open_float,
     { desc = 'Show diagnostic [E]rror messages' })

-- escape in a terminal (outside of escape with vim mode in zsh)
kmap('t', '<C-v><C-v>', '<C-\\><C-n>',
     { noremap = true, desc = 'Terminal Escape' })

---------------------------------------------------------------------
-- mini.nvim keymaps ------------------------------------------------
---------------------------------------------------------------------

-- mini.diff

kmap('n', '<leader>hd', '<cmd>lua MiniDiff.toggle_overlay()<CR>',
     { desc = 'Toggle Diff Overlay' })

-- mini.sessions

kmap('n', '<leader>oo', '<cmd>lua MiniSessions.select(\'read\')<CR>',
     { desc = 'Open Session' })

kmap('n', '<leader>od', '<cmd>lua MiniSessions.select(\'delete\')<CR>',
     { desc = 'Delete Session' })

kmap('n', '<leader>os', function()
    local ok, res = pcall(vim.fn.input, {
        prompt = 'Save session as: ',
        cancelreturn = false,
    })
    if not ok or res == false then
        return nil
    end
    MiniSessions.write(res)
end, { desc = 'Save Session' })

-- mini.jump2d

kmap({ 'o', 'x', 'n' }, '<CR>',
     '<cmd>lua MiniJump2d.start(MiniJump2d.builtin_opts.single_character)<CR>',
     { desc = 'Jump anywhere' })

-- <leader> - mini.pick - search
local pick_maps = {
    { 'sf',       'Pick files',                       '[S]earch [F]iles' },
    { 'se',       'Pick explorer',                    '[S]earch [E]xplorer' },
    { 'sw',       'Pick grep pattern=\'<cword>\'',    '[S]earch [W]ord under cursor' },
    { 'sg',       'Pick grep_live',                   '[S]earch [G]rep live' },
    { '/',        'Pick buf_lines scope=\'current\'', '[/] Search in current buffer' },
    { 's/',       'Pick buf_lines scope=\'all\'',     '[S]earch [/] across all buffers' },
    { 'sh',       'Pick help',                        '[S]earch [H]elp' },
    { 'sk',       'Pick keymaps',                     '[S]earch [K]eymaps' },
    { 'sd',       'Pick diagnostic',                  '[S]earch [D]iagnostics' },
    { 'sl',       'Pick list scope=\'location\'',     '[S]earch [L]ocation list' },
    { 'st',       'Pick hipatterns',                  '[S]earch [T]odos' },
    { 'sm',       'Pick marks',                       '[S]earch [M]arks' },
    { 'sc',       'Pick commands',                    '[S]earch [C]ommands' },
    { 'sr',       'Pick resume',                      '[S]earch [R]esume' },
    { 'so',       'Pick oldfiles',                    '[S]earch [O]ld (recent) files' },
    { '<leader>', 'Pick buffers_with_delete',         '[ ] Search current buffers' },
    { 'sn',       'Pick neovim_config',               '[S]earch [N]eovim files' },
    { 'ss',       'Pick registry',                    '[S]earch [S]earch Pick registry' },
}
for _, m in ipairs(pick_maps) do
    kmap('n', '<leader>' .. m[1], '<cmd>' .. m[2] .. '<CR>', { desc = m[3] })
end

-- <leader>l<.> - mini.pick - lsp keymaps
local lsp_pick_maps = {
    { 'lD', 'Pick lsp scope=\'declaration\'',      '[L]SP [D]eclaration' },
    { 'ld', 'Pick lsp scope=\'definition\'',       '[L]SP [D]efinition' },
    { 'lt', 'Pick lsp scope=\'type_definition\'',  '[L]SP [T]ype Definition' },
    { 'lr', 'Pick lsp scope=\'references\'',       '[L]SP [R]eference' },
    { 'li', 'Pick lsp scope=\'implementation\'',   '[L]SP [I]mplementation' },
    { 'ls', 'Pick lsp scope=\'document_symbol\'',  '[L]SP [S]ymbols buffer' },
    { 'lS', 'Pick lsp scope=\'workspace_symbol\'', '[L]SP [S]ymbols all buffers' },
}
for _, m in ipairs(lsp_pick_maps) do
    kmap('n', '<leader>' .. m[1], '<cmd>' .. m[2] .. '<CR>', { desc = m[3] })
end

kmap('n', '<leader>lR', vim.lsp.buf.rename,
     { desc = '[L]SP [R]ename symbol' })

kmap('n', '<leader>lh', vim.lsp.buf.hover,
     { desc = '[L]SP [H]over documentation' })

-- export map function for use in other files
return { kmap = kmap }
