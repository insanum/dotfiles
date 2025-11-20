-- PDF and Excalidraw utilities

local config = require('notes.config')
local utils = require('notes.utils')

local M = {}

-- Open PDF in external app
local function run_pdf_expert(file_path)
    vim.notify('Opening "' .. file_path .. '"', vim.log.levels.INFO)
    vim.system({ 'open', file_path }, function()
        vim.notify('Done editing "' .. file_path .. '"', vim.log.levels.INFO)
    end)
end

-- Open PDF from file link under cursor
function M.open()
    local file = vim.fn.expand('<cfile>:t')
    if not string.match(file, '%.pdf$') then
        vim.notify('PDF only', vim.log.levels.ERROR)
        return
    end

    local file_path = config.pdf_dir .. file

    if vim.fn.filereadable(file_path) == 0 then
        vim.notify('PDF doesn\'t exist', vim.log.levels.ERROR)
        return
    end

    utils.confirm_and_run('Open "' .. file .. '"', function()
        run_pdf_expert(file_path)
    end)
end

-- Run Excalidraw on a file
local function run_excalidraw(efile_path)
    if vim.fn.filereadable(efile_path) == 0 then
        if vim.fn.filereadable(config.excli_blank) == 0 then
            vim.notify('Blank Excalidraw file not found',
                       vim.log.levels.ERROR)
            return
        end

        vim.system({ 'cp', '-f', config.excli_blank, efile_path }):wait()
    end

    vim.notify('Opening "' .. efile_path .. '"', vim.log.levels.INFO)
    vim.system({ 'excli', efile_path }, function()
        vim.notify('Done editing "' .. efile_path .. '"', vim.log.levels.INFO)
    end)
end

-- Edit Excalidraw image under cursor
function M.edit_excalidraw()
    local file = vim.fn.expand('<cfile>')
    if not string.match(file, '%.excalidraw.png$') then
        vim.notify('Excalidraw/PNG only', vim.log.levels.ERROR)
        return
    end

    local efile = string.gsub(file, '^(.+).png$', '%1')

    local file_path = config.assets_dir .. file
    local efile_path = config.assets_dir .. efile

    local prompt = 'Edit "' .. efile .. '"'
    if vim.fn.filereadable(file_path) == 0 then
        prompt = 'Create and ' .. prompt
    end

    utils.confirm_and_run(prompt, function()
        run_excalidraw(efile_path)
    end)
end

return M
