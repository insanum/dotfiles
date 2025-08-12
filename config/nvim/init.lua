
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

if vim.g.vscode then
    return
end

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
    local out = vim.fn.system {
        'git',
        'clone',
        '--filter=blob:none',
        '--branch=stable',
        'https://github.com/folke/lazy.nvim.git',
        lazypath
    }
    if vim.v.shell_error ~= 0 then
        error('Error cloning lazy.nvim:\n' .. out)
    end
end

vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
    {
        import = 'plugins',
        change_detection = {
            notify = false,
        },
        ui = {
            icons = {},
        },
    },
})

-- To use blink.cmp...
--   - uncomment vim.lsp.enable() call below
--   - disable cmp.lua
--   - disable lsp.lua
--   - enable blink-compat.lua
--   - enable blink.lua
--   - :Lazy (U|X)

-- Original configs:
--   https://github.com/neovim/nvim-lspconfig/tree/master/lua/lspconfig/configs
-- Mason installs: [ vim.fn.stdpath('data') .. '/mason/bin' ]
-- New LSP configs: lsp/*.lua
-- vim.lsp.enable({
--     'bashls',
--     'clangd',
--     'lua_ls',
--     'pyright',
--     'rust_analyzer',
--     'ts_ls',
--     'zls',
-- })

-- highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking (copying) text',
    group = vim.api.nvim_create_augroup('insanum-yank', { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})

require('options')
require('autocmds')
require('keymaps')
require('highlights')

