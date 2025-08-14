
vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'markdown' },
    callback = function()
        -- set this if indent-o-matic.nvim isn't working
        --vim.opt.shiftwidth = 4

        vim.opt.colorcolumn = ''
        vim.opt.wrap = true
        vim.opt.linebreak = true
        vim.opt.textwidth = 0
        vim.opt.wrapmargin = 0
        vim.opt.formatoptions:remove('l')
        vim.opt.formatoptions:append('ro')
        vim.opt.comments = 'fb:-,fb:+,fb:*,fb:>,fb:|'
        vim.opt.formatlistpat = '^\\s*\\d\\+\\.\\s\\+\\|^\\s*[-*+]\\s\\+'
        vim.opt.breakindentopt = 'list:-1'

        vim.keymap.set('n', 'j', 'v:count == 0 ? "gj" : "j"',
                       { expr = true, noremap = true })
        vim.keymap.set('n', 'k', 'v:count == 0 ? "gk" : "k"',
                       { expr = true, noremap = true })
    end
})

-- update yaml frontmatter on markdown files when saving
vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
    pattern = '*.md',
    callback = function()
        local bufnr = vim.api.nvim_get_current_buf()

        -- bail if buffer hasn't been modified
        if not vim.api.nvim_buf_get_option(bufnr, 'modified') then
            return
        end

        -- bail if buffer isn't of type markdown
        if vim.bo.filetype ~= 'markdown' then
            return
        end

        -- get the lines for this buffer
        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

        -- get the current date and time
        local updated_time = os.date('%Y-%m-%dT%H:%M')
        local created_time = updated_time

        -- helper to replace the lines in the buffer
        local function set_buf_lines(new_lines)
            vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, new_lines)
        end

        -- helper to create a default yaml frontmatter block
        local function default_frontmatter()
            return {
                '---',
                'created: ' .. created_time,
                'updated: ' .. updated_time,
                '---',
            }
        end

        -- detect if the yaml frontmatter exists or not
        if #lines == 0 or lines[1] ~= '---' then
            -- no yaml frontmatter, create it with the updated time
            local new_lines = vim.list_extend(default_frontmatter(), lines)
            set_buf_lines(new_lines)
            return
        end

        -- find the end of the yaml frontmatter
        local frontmatter_end = nil
        for i = 2, #lines do
            if lines[i] == '---' then
                frontmatter_end = i
                break
            end
        end
        -- if not found then frontmater is malformed, bail
        if not frontmatter_end then
            return
        end

        -- attributre found flags
        local found_created = false
        local created_index = 0
        local found_updated = false

        -- update or insert the attributes
        for i = 2, frontmatter_end - 1 do
            if lines[i]:match('^created:') then
                found_created = true
                created_index = i
            elseif lines[i]:match('^updated:') then
                found_updated = true
                lines[i] = 'updated: ' .. updated_time
            end
        end

        if not found_created then
            table.insert(lines, 2, 'created: ' .. created_time)
            created_index = 2
        end

        if not found_updated then
            table.insert(lines, created_index + 1, 'updated: ' .. updated_time)
        end

        set_buf_lines(lines)
    end,
})

local pick = require('mini.pick')

vim.keymap.set('n', '<leader>ng', function()
                   vim.ui.input({ prompt = 'Tag: ' }, function(input)
                       if not input or input == '' then
                           return
                       end

                       pick.builtin.grep({
                           globs = { '*.md' },
                           pattern = '\\s#' .. input .. '[\\s|/]',
                       })
                   end)
               end,
               { desc = '[N]otes Ta[G]s' })

vim.keymap.set('n', '<leader>nto', function()
                   pick.builtin.grep({
                       globs = { '*.md' },
                       pattern = [[^\s*- \[ \] ]],
                   })
               end,
               { desc = '[N]otes [T]asks [O]pen' })

vim.keymap.set('n', '<leader>ntc', function()
                   pick.builtin.grep({
                       globs = { '*.md' },
                       pattern = [[\s\[completion:: ]],
                   })
               end,
               { desc = '[N]otes [T]asks [C]ompleted' })

vim.keymap.set('n', '<leader>ntp', function()
                   pick.builtin.grep({
                       globs = { '*.md' },
                       pattern = [[\s\[punted:: ]],
                   })
               end,
               { desc = '[N]otes [T]asks [P]unted' })

local ToggleDataviewTag = function(tag, tag_pattern)
    -- get the current line in the buffer
    local l_num = vim.api.nvim_win_get_cursor(0)[1]
    local l = vim.api.nvim_buf_get_lines(0, l_num - 1, l_num, false)[1]

    -- add or remove the tag
    if l:find(tag_pattern) then
        l = l:gsub('%s*' .. tag_pattern, '')
    else
        l = l:gsub('%s*$', '') .. ' ' .. tag
    end

    -- update the line in the buffer
    vim.api.nvim_buf_set_lines(0, l_num - 1, l_num, false, { l })
end

vim.keymap.set('n', '<leader>nc', function()
                   local tag = '[completion:: ' .. os.date('%Y-%m-%d') .. ']'
                   local tag_pattern = '%[completion:: %d%d%d%d%-%d%d%-%d%d%]$'
                   ToggleDataviewTag(tag, tag_pattern)
               end,
               { desc = '[N]otes [C]omplete Task' })

vim.keymap.set('n', '<leader>np', function()
                   local tag = '[punted:: ' .. os.date('%Y-%m-%d') .. ']'
                   local tag_pattern = '%[punted:: %d%d%d%d%-%d%d%-%d%d%]$'
                   ToggleDataviewTag(tag, tag_pattern)
               end,
               { desc = '[N]otes [P]unted Task' })

