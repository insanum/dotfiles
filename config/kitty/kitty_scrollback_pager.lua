
local tmpfile = vim.fn.expand('%')

-- nop insert-mode keys, this is global for all buffers
for _, key in ipairs({ 'i', 'I', 'a', 'A', 'o', 'O', 'c', 'C', 's', 'S' }) do
    vim.keymap.set('n', key, '<nop>', { buffer = false })
end

vim.keymap.set('n', 'q', '<cmd>qa!<CR>')

-- open a terminal buffer with the scrollback content
vim.cmd('terminal cat ' .. vim.fn.shellescape(tmpfile))
vim.cmd('stopinsert')

vim.api.nvim_create_autocmd('TermClose', {
    once = true,
    callback = function()
        vim.schedule(function()
            vim.opt_local.modifiable = false
            vim.opt_local.number = true
            vim.opt_local.relativenumber = true
            vim.cmd('normal! G')
        end)
    end,
})

