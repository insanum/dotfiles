-- Journal management: daily and weekly entries

local config = require('notes.config')
local pick   = require('mini.pick')

-- Helper function to get journal file path for a given date
local function journal_entry_path(date_str)
    return config.journal_dir .. '/' .. date_str .. '.md'
end

-- Helper function to get the current date
local function current_date()
    return os.date('%Y-%m-%d')
end

-- Helper function to parse the date from the current buffer or use today
local function current_file_date()
    local current_file = vim.fn.expand('%:t:r') -- filename without extension
    local date_pattern = '^%d%d%d%d%-%d%d%-%d%d$'

    if current_file:match(date_pattern) then
        return current_file
    else
        return current_date()
    end
end

-- Helper function to add/subtract days from a date string
local function adjust_date(date_str, days)
    local year, month, day = date_str:match('(%d+)-(%d+)-(%d+)')
    if not year then
        return nil
    end

    local time = os.time({ year = year, month = month, day = day })
    local new_time = (time + (days * 24 * 60 * 60))
    return os.date('%Y-%m-%d', new_time)
end

-- Helper function to open journal file
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

-- In { YYYY-MM-DD }, out { year, week_number, sunday_date, saturday_date }
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

-- In "YYYY-wWW", out { sunday_date_long, sunday_date, saturday_date }
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

-- Helper function to get the week file path
local function journal_week_path(year, week)
    return string.format('%s/%04d-w%02d.md', config.journal_dir, year, week)
end

-- Helper function to open a journal week file
local function open_journal_week_entry(year, week)
    local journal_week_file = journal_week_path(year, week)

    -- if the file doesn't exist, create it with a template
    if vim.fn.filereadable(journal_week_file) == 0 then
        local sun_date_long, sun_date, sat_date =
            week_to_date(string.format('%04d-w%02d', year, week))

        local formatted_date = string.format('# %d %s-%s (w%02d)',
                                             year, sun_date, sat_date, week)
        local timestamp = os.date('%Y-%m-%dT%H:%M')

        local content = {
            '---',
            'created: ' .. timestamp,
            'updated: ' .. timestamp,
            '---',
            '',
            formatted_date,
            '',
            '---',
            '',
        }

        for i = 0, 6 do
            local day_date = adjust_date(sun_date_long, i)
            table.insert(content, string.format('![[Journal/%s]]', day_date))
            table.insert(content, '')
        end

        vim.fn.mkdir(vim.fn.fnamemodify(journal_week_file, ':h'), 'p')
        vim.fn.writefile(content, journal_week_file)
    end

    vim.cmd('edit ' .. journal_week_file)
end

-- Open journal entry for a specific date (or with offset)
local function open_day(opts)
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
end

-- Open journal week entry (or with offset)
local function open_week(opts)
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
end

-- Show missing journal day entries
local function missing_days()
    local missing_dates = {}
    local date_t = os.time()

    for i = 0, 365 do
        local tmp_date_t = (date_t - (i * 86400)) -- subtract i days

        local tmp_date_str = os.date('%Y-%m-%d', tmp_date_t)
        local journal_file = journal_entry_path(tmp_date_str)

        if vim.fn.filereadable(journal_file) == 0 then
            missing_dates[#missing_dates + 1] = tmp_date_str
        end
    end

    local date = pick.start({
        source = {
            name = 'Missing Journal Entries',
            items = missing_dates,
        }
    })

    if not date then
        return
    end

    open_journal_date_entry(date)
end

-- Show missing journal week entries
local function missing_weeks()
    local missing = {}
    local date_t = os.time()

    for i = 0, 52 do
        local tmp_date_t = (date_t - (i * 608400)) -- subtract i weeks

        local tmp_date_str = os.date('%Y-%m-%d', tmp_date_t)
        local year, week = date_to_week(tmp_date_str)

        local journal_week_file = journal_week_path(year, week)

        if vim.fn.filereadable(journal_week_file) == 0 then
            missing[#missing + 1] = { year = year, week = week }
        end
    end

    local week = pick.start({
        source = {
            name = 'Missing Journal Week Entries',
            items = missing,
            show = function(buf_id, items, query)
                local display_items = {}
                for _, item in ipairs(items) do
                    table.insert(display_items,
                                 string.format('%04d-w%02d',
                                               item.year,
                                               item.week))
                end
                return pick.default_show(buf_id, display_items, query,
                                         { show_icons = true })
            end,
        }
    })

    if not week then
        return
    end

    open_journal_week_entry(week.year, week.week)
end

-- register commands

vim.api.nvim_create_user_command('Journal', open_day,
    { desc = 'Open journal entry (use +N/-N for offset)', nargs = '?' })

vim.api.nvim_create_user_command('JournalWeek', open_week,
    { desc = 'Open journal week entry (use +N/-N for offset)', nargs = '?' })

vim.api.nvim_create_user_command('JournalMissing', missing_days,
    { desc = 'List missing journal entries', nargs = '?' })

vim.api.nvim_create_user_command('JournalWeekMissing', missing_weeks,
    { desc = 'List missing journal week entries', nargs = '?' })

