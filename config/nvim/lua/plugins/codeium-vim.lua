-- This version of Codeium seems to work well for me. This one is Vim based
-- and shows generations as ghost text. Problem is that the ghost text
-- conflicts with nvim-cmp if the expiremental ghost text feature in nvim-cmp
-- is enabled (w/ behaviour='Select').
return {
    'Exafunction/codeium.vim',
    enabled = false,
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
}
