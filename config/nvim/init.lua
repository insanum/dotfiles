
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

local path = vim.fn.stdpath('config') .. '/lua/plugins'
local plugs = {}

-- load all plugins specs under 'lua/plugins' into a table
for name, type in vim.fs.dir(path) do
    if (type == 'file' or type == 'link') and name:match('%.lua$') then
        local m = require('plugins.' .. name:gsub('%.lua$', ''))
        if not m.disabled then
            table.insert(plugs, m)
        end
    end
end

-- sort the plugin table by 'priority' (lower value = higher priority)
table.sort(plugs, function(a, b)
    return (a.priority or 100) < (b.priority or 100)
end)

--[[
Load the plugins in order by doing the following:
  - call the 'pre_pack_add()' function if defined
  - add the dependencies to vim.pack if the 'depends' field is defined
  - add the plugin to vim.pack
  - if the 'setup' field is true (default), call the plugin's 'setup()'
    function passing it the 'opts' field (if defined else an empty table)
  - call the 'post_setup()' function if defined
--]]
for _, m in ipairs(plugs) do
    if m.pre_pack_add then m.pre_pack_add() end
    if m.depends then vim.pack.add(m.depends) end
    vim.pack.add(m.plug)

    if m.setup ~= false then
        local ok, plugin = pcall(require, m.name)
        if ok and plugin.setup then
            pcall(plugin.setup, m.opts or {})
        end
    end

    if m.post_setup then m.post_setup() end
end

require('options')
require('autocmds')
require('keymaps')
require('notes')
require('highlights')
require('pack')

