
local notes_dir = '/Volumes/work/notes'

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
        -- Using markdown-toggle.nvim instead of these...
        -- vim.opt.formatoptions:append('ro')
        -- vim.opt.comments = 'b:- [ ],b:-,b:>,b:|'
        vim.opt.formatlistpat = '^\\s*\\d\\+\\.\\s\\+\\|^\\s*-\\s\\+'
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

-- helper function to toggle a tag on the current line
local function toggle_dataview_tag(tag, tag_pattern)
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
                   toggle_dataview_tag(tag, tag_pattern)
               end,
               { desc = '[N]otes [C]omplete Task' })

vim.keymap.set('n', '<leader>np', function()
                   local tag = '[punted:: ' .. os.date('%Y-%m-%d') .. ']'
                   local tag_pattern = '%[punted:: %d%d%d%d%-%d%d%-%d%d%]$'
                   toggle_dataview_tag(tag, tag_pattern)
               end,
               { desc = '[N]otes [P]unted Task' })

------------------------------------------------------------------------------
-- JOURNAL DAY ---------------------------------------------------------------
------------------------------------------------------------------------------

-- helper function to get journal file path for a given date
local function journal_entry_path(date_str)
    local journal_dir = notes_dir .. '/Journal'
    return journal_dir .. '/' .. date_str .. '.md'
end

-- helper function to get the current date
local function current_date()
        return os.date('%Y-%m-%d')
end

-- helper function to parse the date from the current buffer or use today
local function current_file_date()
    local current_file = vim.fn.expand('%:t:r') -- filename without extension
    local date_pattern = '^%d%d%d%d%-%d%d%-%d%d$'

    if current_file:match(date_pattern) then
        return current_file
    else
        return current_date()
    end
end

-- helper function to add/subtract days from a date string
local function adjust_date(date_str, days)
    local year, month, day = date_str:match('(%d+)-(%d+)-(%d+)')
    if not year then
        return nil
    end

    local time = os.time({ year = year, month = month, day = day })
    local new_time = (time + (days * 24 * 60 * 60))
    return os.date('%Y-%m-%d', new_time)
end

-- helper function to open journal file
local function open_journal_date_entry(date_str)
    local journal_file = journal_entry_path(date_str)

    -- if the file doesn't exist, create it with a template
    if vim.fn.filereadable(journal_file) == 0 then
        local year, month, day = date_str:match('(%d+)-(%d+)-(%d+)')

        local date_t = os.time({ year = year, month = month, day = day })
        local formatted_date = os.date('# %a %m/%d/%Y', date_t)
        local timestamp = os.date('%Y-%m-%dT%H:%M')

        vim.fn.mkdir(vim.fn.fnamemodify(journal_file, ':h'), 'p')
        vim.fn.writefile({
                             '---',
                             'created: ' .. timestamp,
                             'updated: ' .. timestamp,
                             '---',
                             '',
                             formatted_date,
                             '',
                             '',
                         }, journal_file)
    end

    vim.cmd('edit ' .. journal_file)
end

-- journal entry command with offset support
vim.api.nvim_create_user_command('Journal', function(opts)
    local date = current_date()
    local offset = 0

    -- parse the argument if provided
    if opts.args and opts.args ~= '' then
        local sign = nil
        sign, offset = opts.args:match('^([%+%-]?)(%d+)$')
        if not offset then
            vim.notify('Invalid offset, use +N/-N', vim.log.levels.ERROR)
            return
        end

        if sign == '-' then
            offset = -offset
        end

        date = current_file_date()
    end

    local target_date = adjust_date(date, offset)

    if not target_date then
        vim.notify('Could not determine target date', vim.log.levels.ERROR)
        return
    end

    open_journal_date_entry(target_date)
end, { desc = 'Open journal entry (use +N/-N for offset)', nargs = '?' })

vim.keymap.set('n', '<leader>jt', '<Cmd>Journal<CR>',
               { desc = '[J]ournal [T]oday' })
vim.keymap.set('n', '<leader>jp', '<Cmd>Journal -1<CR>',
               { desc = '[J]ournal [P]rev' })
vim.keymap.set('n', '<leader>jn', '<Cmd>Journal +1<CR>',
               { desc = '[J]ournal [N]ext' })

------------------------------------------------------------------------------
-- JOURNAL WEEK --------------------------------------------------------------
------------------------------------------------------------------------------

-- in { YYYY-MM-DD }, out { year, week_number, sunday_date, saturday_date }
local function date_to_week(date_str)
    local y, m, d = date_str:match('^(%d+)%-(%d+)%-(%d+)$')

    -- the time defaults to 12pm/noon on the specified date
    -- could include { hour = 0, min = 0, sec = 0 } to get midnight
    local date_t = os.time({
        year = y,
        month = m,
        day = d,
        isdst = false
    })

    local jan1_t = os.time({
        year = y,
        month = 1,
        day = 1,
        isdst = false
    })

    local date_tbl = os.date('!*t', date_t)
    local jan1_tbl = os.date('!*t', jan1_t)

    -- the Sunday of the date's week
    local date_sun_t = os.time({
        year = y,
        month = m,
        day = (d - (date_tbl.wday - 1)),
        isdst = false,
    })

    -- the Sunday of Jan 1st's week
    -- if Jan 1 is not on a Sunday, adjust the year/month/day
    local jan1_sun_year = y
    local jan1_sun_month = 1
    local jan1_sun_day = 1
    if jan1_tbl.wday > 1 then
        jan1_sun_year = (y - 1)
        jan1_sun_month = 12
        jan1_sun_day = (31 - (jan1_tbl.wday - 1) + 1)
    end

    local jan1_sun_t = os.time({
        year = jan1_sun_year,
        month = jan1_sun_month,
        day = jan1_sun_day,
        isdst = false,
    })

    local week_num = (((os.difftime(date_sun_t, jan1_sun_t) / 86400) / 7) + 1)

    return y, week_num,
           os.date('%m/%d', date_sun_t),
           os.date('%m/%d', (date_sun_t + (6 * 86400)))
end

-- in { year, week }, out { sunday_date_long, sunday_date, saturday_date }
local function week_to_date(week_str)
    local y, wn = week_str:match('^(%d+)%-w(%d+)$')

    local jan1_t = os.time({
        year = y,
        month = 1,
        day = 1,
        isdst = false
    })

    local jan1_tbl = os.date('*t', jan1_t)

    -- the Sunday of Jan 1st's week
    -- if Jan 1 is not on a Sunday, adjust the year/month/day
    local jan1_sun_year = y
    local jan1_sun_month = 1
    local jan1_sun_day = 1
    if jan1_tbl.wday > 1 then
        jan1_sun_year = (y - 1)
        jan1_sun_month = 12
        jan1_sun_day = (31 - (jan1_tbl.wday - 1) + 1)
    end

    local jan1_sun_t = os.time({
        year = jan1_sun_year,
        month = jan1_sun_month,
        day = jan1_sun_day,
        isdst = false,
    })

    -- add the number of weeks to Jan 1st's Sunday
    local sun_t = (jan1_sun_t + (86400 * (7 * (wn - 1))))
    local sat_t = (sun_t + (6 * 86400))

    return os.date('%Y-%m-%d', sun_t),
           os.date('%m/%d', sun_t),
           os.date('%m/%d', sat_t)
end

-- helper function to get the week file path
local function journal_week_path(year, week)
    local journal_dir = notes_dir .. '/Journal'
    return string.format('%s/%04d-w%02d.md', journal_dir, year, week)
end

-- helper function to open a journal week file
local function open_journal_week_entry(year, week)
    local journal_week_file = journal_week_path(year, week)

    -- if the file doesn't exist, create it with a template
    if vim.fn.filereadable(journal_week_file) == 0 then
        local _, sun_date, sat_date =
            week_to_date(string.format('%04d-w%02d', year, week))

        local formatted_date = string.format('# %d %s-%s (w%02d)',
                                             year, sun_date, sat_date, week)
        local timestamp = os.date('%Y-%m-%dT%H:%M')

        vim.fn.mkdir(vim.fn.fnamemodify(journal_week_file, ':h'), 'p')
        vim.fn.writefile({
                             '---',
                             'created: ' .. timestamp,
                             'updated: ' .. timestamp,
                             '---',
                             '',
                             formatted_date,
                             '',
                             '',
                         }, journal_week_file)
    end

    vim.cmd('edit ' .. journal_week_file)
end

-- journal week command with offset support
vim.api.nvim_create_user_command('JournalWeek', function(opts)
    local date = current_date()
    local offset = 0

    -- parse the argument if provided
    if opts.args and opts.args ~= '' then
        local sign = nil
        sign, offset = opts.args:match('^([%+%-]?)(%d+)$')
        if not offset then
            vim.notify('Invalid offset, use +N/-N', vim.log.levels.ERROR)
            return
        end

        if sign == '-' then
            offset = -offset
        end

        local current_file = vim.fn.expand('%:t:r') -- filename without extension
        if current_file:match('^%d%d%d%d%-w%d%d$') then
            date, _, _ = week_to_date(current_file)
        end
    end

    local year, week = date_to_week(date)
    if not year or not week then
        vim.notify('Could not determine target week', vim.log.levels.ERROR)
        return
    end

    -- FIXME handle week/year wrapping before or after Jan 1st
    local target_week = (week + offset)
    local target_year = year

    if target_week < 1 or target_week >= 53 then
        vim.notify('Wrapping week number', vim.log.levels.ERROR)
        return
    end

    open_journal_week_entry(target_year, target_week)
end, { desc = 'Open journal week entry (use +N/-N for offset)', nargs = '?' })

vim.keymap.set('n', '<leader>jw', '<Cmd>JournalWeek<CR>',
               { desc = '[J]ournal [W]eek' })
vim.keymap.set('n', '<leader>jP', '<Cmd>JournalWeek -1<CR>',
               { desc = '[J]ournal Week [P]rev' })
vim.keymap.set('n', '<leader>jN', '<Cmd>JournalWeek +1<CR>',
               { desc = '[J]ournal Week [N]ext' })

