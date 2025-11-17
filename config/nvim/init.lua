
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

if vim.g.vscode then
    return
end

-- clone 'mini.nvim' if doesn't exist (needed for mini.deps)
local path_package = vim.fn.stdpath('data') .. '/site/'
local mini_path = path_package .. 'pack/deps/start/mini.nvim'
if not vim.uv.fs_stat(mini_path) then
    vim.cmd('echo "Installing `mini.nvim`" | redraw')
    local out = vim.fn.system({
        'git', 'clone', '--filter=blob:none',
        'https://github.com/nvim-mini/mini.nvim',
        mini_path
    })
    if vim.v.shell_error ~= 0 then
        error('Error cloning mini.nvim:\n' .. out)
    end
    vim.cmd('packadd mini.nvim | helptags ALL')
    vim.cmd('echo "Installed mini.nvim" | redraw')
end

require('mini.deps').setup({
    path = {
        package = path_package,
    },
})

-- walk all plugins under 'lua/plugins' and load them using 'mini.deps'
-- FIXME include an M.priority and sort, then load in that order
local config_dir = 'plugins'
local path = vim.fn.stdpath('config') .. '/lua/' .. config_dir
for name, type in vim.fs.dir(path) do
    if (type == 'file' or type == 'link') and name:match('%.lua$') then
        local plugin = config_dir .. '.' .. name:gsub('%.lua$', '')
        local m = require(plugin)
        if not m.disabled then
            if m.now then
                MiniDeps.now(function() m.setup(MiniDeps.add) end)
            else
                MiniDeps.later(function() m.setup(MiniDeps.add) end)
            end
        end
    end
end

require('options')
require('autocmds')
require('keymaps')
require('notes')
require('highlights')

