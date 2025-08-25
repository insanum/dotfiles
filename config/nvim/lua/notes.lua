
local notes_dir = '/Volumes/work/notes'

-- set the default config for markdown files
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

-- search for tags
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

-- search for open tasks
vim.keymap.set('n', '<leader>nto', function()
                   pick.builtin.grep({
                       globs = { '*.md' },
                       pattern = [[^\s*- \[ \] ]],
                   })
               end,
               { desc = '[N]otes [T]asks [O]pen' })

-- search for completed tasks
vim.keymap.set('n', '<leader>ntc', function()
                   pick.builtin.grep({
                       globs = { '*.md' },
                       pattern = [[\s\[completion:: ]],
                   })
               end,
               { desc = '[N]otes [T]asks [C]ompleted' })

-- search for punted tasks
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

-- toggle completion
vim.keymap.set('n', '<leader>nc', function()
                   local tag = '[completion:: ' .. os.date('%Y-%m-%d') .. ']'
                   local tag_pattern = '%[completion:: %d%d%d%d%-%d%d%-%d%d%]$'
                   toggle_dataview_tag(tag, tag_pattern)
               end,
               { desc = '[N]otes [C]omplete Task' })

-- toggle punted
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

vim.keymap.set('n', '<leader>jd', '<Cmd>Journal<CR>',
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

------------------------------------------------------------------------------
-- JOURNAL ENTRIES MISSING ---------------------------------------------------
------------------------------------------------------------------------------

-- journal missing command
vim.api.nvim_create_user_command('JournalMissing', function(opts)
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
            name = "Missing Journal Entries",
            items = missing_dates,
        }
    })

    if not date then
        return
    end

    open_journal_date_entry(date)
end, { desc = 'List missing journal entries', nargs = '?' })

vim.keymap.set('n', '<leader>jm', '<Cmd>JournalMissing<CR>',
               { desc = '[J]ournal [M]issing' })

------------------------------------------------------------------------------
-- READING LIST PICKER -------------------------------------------------------
------------------------------------------------------------------------------

local function yaml_property_value(path, property)
    local file = io.open(path, 'r')
    if not file then
        return nil
    end

    local content = file:read('*all')
    file:close()

    if not content:match('^%-%-%-\n') then
        return nil
    end

    local yaml_end = content:find('\n%-%-%-\n', 4)
    if not yaml_end then
        return nil
    end

    local yaml = content:sub(4, yaml_end - 1)
    local p_value = yaml:match(property .. ':%s*([^\n]+)')

    if not p_value then
        return nil
    end

    return p_value:gsub('^%s*', ''):gsub('%s*$', '')
end

pick.registry.reading_list = function(local_opts)
    return pick.builtin.cli(
        {
            command = {
                'fd', '-e', 'md', '-g', '*.md',
            },
            postprocess = function(lines)
                local filtered_lines = {}

                local p_name = nil
                if local_opts.type == 'all' then
                    p_name = 'created'
                elseif local_opts.type == 'completed' then
                    p_name = 'completion'
                elseif local_opts.type == 'punted' then
                    p_name = 'punted'
                end

                for _, line in ipairs(lines) do
                    local p_value = nil
                    if p_name then
                        p_value = yaml_property_value(line, p_name)
                    else
                        -- this is the 'todo' type
                        if not yaml_property_value(line, 'completion') and
                           not yaml_property_value(line, 'punted') then
                            p_value = yaml_property_value(line, 'created')
                        end
                    end
                    if p_value then
                        table.insert(filtered_lines, {
                            path = line,
                            date = p_value,
                        })
                    end
                end

                -- property is expected to be a date (YYYY-MM-DD format)
                table.sort(filtered_lines, function(a, b)
                    local function parse_date(date_str)
                        local year, month, day =
                            date_str:match('^(%d+)%-(%d+)%-(%d+)')

                        if not year or not month or not day then
                            return 0
                        end

                        return os.time({
                            year = year,
                            month = month,
                            day = day,
                        })
                    end

                    return parse_date(a.date) > parse_date(b.date)
                end)

                return filtered_lines
            end
        },
        {
            source = {
                cwd = notes_dir .. '/' .. local_opts.dir,
                name = 'Read: ' .. local_opts.type,
                show = function(buf_id, items, query)
                    local display_items = {}
                    for _, item in ipairs(items) do
                        table.insert(display_items,
                                     string.format('%s | %s',
                                                   item.date,
                                                   item.path))
                    end
                    return pick.default_show(buf_id, display_items, query,
                                             { show_icons = true })
                end,
            },
        }
    )
end

vim.keymap.set('n', '<leader>nra',
               '<cmd>Pick reading_list dir=\'PDFs\' type=\'all\'<CR>',
               { desc = '[N]otes [R]ead [A]ll' })

vim.keymap.set('n', '<leader>nrt',
               '<cmd>Pick reading_list dir=\'PDFs\' type=\'todo\'<CR>',
               { desc = '[N]otes [R]ead [T]odo' })

vim.keymap.set('n', '<leader>nrc',
               '<cmd>Pick reading_list dir=\'PDFs\' type=\'completed\'<CR>',
               { desc = '[N]otes [R]ead [C]ompleted' })

vim.keymap.set('n', '<leader>nrp',
               '<cmd>Pick reading_list dir=\'PDFs\' type=\'punted\'<CR>',
               { desc = '[N]otes [R]ead [P]unted' })

------------------------------------------------------------------------------
-- TAG MANAGEMENT ------------------------------------------------------------
------------------------------------------------------------------------------

-- returns the start/end line index of the yaml frontmatter
-- these values are 0-based (end index is exclusive), for nvim_buf_get_lines
-- range does NOT include the '---' lines
local function get_yaml_bounds()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

    if #lines == 0 or lines[1] ~= '---' then
        return nil, nil
    end

    for i = 2, #lines do
        if lines[i] == '---' then
            return 1, i - 1
        end
    end

    return nil, nil
end

-- returns the start/end line index of the yaml frontmatter
-- returns the list of tags (empty if none)
-- returns the start/end line index of the tag property
-- these values are 0-based (end index is exclusive), for nvim_buf_get_lines
-- range does NOT include the '---' lines
local function get_yaml_tags()
    local yaml_start, yaml_end = get_yaml_bounds()
    if not yaml_start then
        return nil, nil, {}, nil, nil
    end

    local lines = vim.api.nvim_buf_get_lines(0, yaml_start, yaml_end, false)
    local tags = {}
    local tags_start = nil
    local tags_end = nil
    local in_tags = false

    for i, line in ipairs(lines) do
        if line:match('^tags:') then
            tags_start = yaml_start + i - 1
            in_tags = true
        elseif in_tags then
            local tag = line:match('^%s*-%s*(.+)')
            if tag then
                local t = tag:gsub('%s*$', '')
                table.insert(tags, t)
                tags_end = yaml_start + i
            elseif not line:match('^%s*$') then
                in_tags = false
                break
            end
        end
    end

    return yaml_start, yaml_end, tags, tags_start, tags_end
end

local function tag_add()
    if vim.bo.filetype ~= 'markdown' then
        vim.notify('Markdown files only', vim.log.levels.WARN)
        return
    end

    vim.ui.input({ prompt = 'Enter tag to add: ' }, function(tag)
        if not tag or tag == '' then
            return
        end

        tag = tag:gsub('^%s*', ''):gsub('%s*$', '')

        local yaml_start, yaml_end, tags, _, tags_end = get_yaml_tags()

        if not yaml_start then
            -- no yaml frontmatter, create it
            local new_yaml = {
                '---',
                'tags:',
                '  - ' .. tag,
                '---',
                ''
            }
            vim.api.nvim_buf_set_lines(0, 0, 0, false, new_yaml)
            vim.notify('Added tag: ' .. tag)
            return
        end

        if #tags > 0 then
            -- check if the tag already exists
            for _, t in ipairs(tags) do
                if t == tag then
                    vim.notify('Tag already exists: ' .. tag)
                    return
                end
            end

            -- add the tag to the property list
            vim.api.nvim_buf_set_lines(0, tags_end, tags_end,
                                       false, { '  - ' .. tag })
        else
            -- there is no tags property, create it
            local new_tags = {
                'tags:',
                '  - ' .. tag
            }

            vim.api.nvim_buf_set_lines(0, yaml_end, yaml_end,
                                       false, new_tags)
        end

        vim.notify('Added tag: ' .. tag)
    end)
end

local function tag_remove()
    if vim.bo.filetype ~= 'markdown' then
        vim.notify('Markdown files only', vim.log.levels.WARN)
        return
    end

    local yaml_start, yaml_end, tags, _, _ = get_yaml_tags()

    if not tags or #tags == 0 then
        vim.notify('No tags found', vim.log.levels.WARN)
        return
    end

    vim.ui.select(tags, { prompt = 'Select tag to remove:' },
                  function(selected_tag)
        if not selected_tag then
            return
        end

        local lines = vim.api.nvim_buf_get_lines(0, yaml_start, yaml_end,
                                                 false)
        local new_lines = {}
        local removed_tag = false
        local remaining_tags = 0
        local tags_section_start = nil

        -- walk the yaml creating a new lines table with the tag removed
        for i, line in ipairs(lines) do
            if line:match('^tags:') then
                tags_section_start = i
                table.insert(new_lines, line)
            elseif line:match('^%s*-%s*(.+)') then
                local tag = line:match('^%s*-%s*(.+)')
                tag = tag:gsub('%s+$', '')
                if tag == selected_tag then
                    removed_tag = true
                else
                    table.insert(new_lines, line)
                    remaining_tags = remaining_tags + 1
                end
            else
                table.insert(new_lines, line)
            end
        end

        -- if no tags remain, remove the entire tags section
        if remaining_tags == 0 and tags_section_start then
            local final_lines = {}
            for _, line in ipairs(new_lines) do
                if not line:match('^tags:') then
                    table.insert(final_lines, line)
                end
            end
            new_lines = final_lines
        end

        if removed_tag then
            -- overwrite the entire yaml frontmatter with the new lines
            vim.api.nvim_buf_set_lines(0, yaml_start, yaml_end, false,
                                       new_lines)
            vim.notify('Removed tag: ' .. selected_tag)
        else
            vim.notify('Tag not found: ' .. selected_tag)
        end
    end)
end

vim.keymap.set('n', '<leader>mta', tag_add,
               { desc = '[M]arkdown [T]ag [A]dd' })
vim.keymap.set('n', '<leader>mtr', tag_remove,
               { desc = '[M]arkdown [T]ag [R]emove' })

------------------------------------------------------------------------------
-- KEYMAP HELP ---------------------------------------------------------------
------------------------------------------------------------------------------

-- New picker that lists all the notes keymaps (help!)
local notes_help = {
    '<leader>nh                         Notes Keymap Help',
    '',
    '<leader>ng                         Search Tags',
    '<leader>nto                        Search Open Tasks',
    '<leader>ntc                        Search Completed Tasks',
    '<leader>ntp                        Search Punted Tasks',
    '',
    '<leader>nc                         Toggle Task Completed',
    '<leader>np                         Toggle Task Punted',
    '',
    '<leader>jd   :Journal [+/-N]       Journal Day',
    '<leader>jp   :Journal -1           Journal Previous Day',
    '<leader>jn   :Journal +1           Journal Next Day',
    '',
    '<leader>jw   :JournalWeek [+/-N]   Journal Week',
    '<leader>jP   :JournalWeek -1       Journal Previous Week',
    '<leader>jN   :JournalWeek +1       Journal Next Week',
    '',
    '<leader>jm   :JournalMissing       Missing Journal Days',
    '',
    '<leader>nra                        Reading List All',
    '<leader>nrt                        Reading List Todo',
    '<leader>nrc                        Reading list Completed',
    '<leader>nrp                        Reading List Punted',
    '',
    ' --> markdown commands support dot(.) and visual mode <--',
    '',
    '<leader>ml                         Markdown List',
    '<leader>mo                         Markdown Ordered List',
    '<leader>mc                         Markdown Checkbox',
    '<leader>mq                         Markdown Quote/Callout',
    '<leader>mh                         Markdown Heading',
    '<leader>mta                        Markdown Tag Add',
    '<leader>mtr                        Markdown Tag Remove',
}

pick.registry.notes_help = function()
    pick.start({
        source = {
            items = notes_help,
            name = 'Notes Help',
            choose = function() end
        },
  })
end

vim.keymap.set('n', '<leader>nh',
               '<cmd>Pick notes_help<CR>',
               { desc = '[N]otes [H]elp' })

