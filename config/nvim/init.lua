
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

require('pack')       -- load all plugins
require('highlights') -- configure highlights
require('options')    -- set vim options
require('autocmds')   -- register autocommands
require('keymaps')    -- register keymaps
require('notes')      -- register notes functions and keymaps

