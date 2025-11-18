
local notes_dir = '/Volumes/work/notes'
local pick = require('mini.pick')

------------------------------------------------------------------------------
-- CONSTANTS ------------------------------------------------------------------
------------------------------------------------------------------------------

local PATTERNS = {
    DATE = '%d%d%d%d%-%d%d%-%d%d',
    DATE_ISO = '^%d%d%d%d%-%d%d%-%d%d$',
    CHECKBOX_DONE = '^%s*-%s*%[x%]',
    CHECKBOX_PUNTED = '^%s*-%s*%[%-]',
    CHECKBOX_OPEN = '^%s*-%s*%[%s%]',
    COMPLETION_TAG = '%%[completion:: (%s)%%]',
    PUNTED_TAG = '%%[punted:: (%s)%%]',
}

local RG_DEFAULTS = { '--no-heading', '--line-number', '--color=never' }
local RG_MD_GLOB = { '--glob', '*.md' }

-- set the default config for markdown files
vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'markdown' },
    callback = function()
        -- set this if indent-o-matic.nvim isn't working
        --vim.opt.shiftwidth = 4

        vim.opt.spell = true
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

        vim.keymap.set('n', 'gf',
                       '<cmd>Pick lsp scope=\'definition\'<CR>',
                       { desc = 'Edit file under cursor', noremap = true })
    end
})

------------------------------------------------------------------------------
-- HELPER FUNCTIONS ----------------------------------------------------------
------------------------------------------------------------------------------

-- helper function for y/n confirmation before executing an action
local function confirm_and_run(prompt, action)
    vim.ui.input({ prompt = prompt .. ' (y/n): '}, function(input)
        if input == 'y' or input == 'yes' then
            action()
        end
    end)
end

local function get_file_mtime(filepath)
    local stat = vim.uv.fs_stat(filepath)
    return stat and stat.mtime.sec or 0
end

local function date_to_ts(date_str)
    if not date_str then
        return nil
    end

    local patterns = {
        '(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)', -- ISO 8601 with time (secs)
        '(%d+)-(%d+)-(%d+)T(%d+):(%d+)',       -- ISO 8601 with time (no secs)
        '(%d+)-(%d+)-(%d+)',                   -- ISO 8601 date only
    }

    for _, pattern in ipairs(patterns) do
        local year, month, day, hour, min, sec =
            string.match(date_str, pattern)
        if year then
            return os.time({
                year = year,
                month = month,
                day = day,
                hour = hour or 0,
                min = min or 0,
                sec = sec or 0,
                isdst = false,
            })
        end
    end

    return nil
end

local function yaml_get(filepath)
    local file = io.open(filepath, 'r')
    if not file then
        return nil
    end

    local content = file:read('*all')
    file:close()

    if not string.match(content, '^---\n') then
        return nil
    end

    local yaml = string.match(content, '^---\n(.-)---\n')
    if not yaml then
        return nil
    end

    local data = {}
    local lines = {}
    for line in yaml:gmatch('[^\n]+') do
        table.insert(lines, line)
    end

    local i = 1
    while i <= #lines do
        local line = lines[i]
        local key, value = string.match(line, '^(%w+):%s*(.*)$')
        if not key then
            i = i + 1
            goto continue
        end

        if value and value ~= '' then
            -- simple key-value pair (strip off quotes if present)
            value = string.gsub(value, "^[\"'](.+)[\"']$", '%1')
            data[key] = value
            i = i + 1
            goto continue
        end

        -- check if this is an array property
        local array_items = {}
        local j = i + 1

        while j <= #lines do
            local next_line = lines[j]
            local array_item = string.match(next_line, '^%s*-%s*(.+)$')

            if array_item then
                -- strip off quotes if present
                array_item = string.gsub(array_item, "^[\"'](.+)[\"']$", "%1")
                table.insert(array_items, array_item)
                j = j + 1
            elseif string.match(next_line, '^%s*$') then
                -- skip empty lines within array
                j = j + 1
            else
                -- not an array item, break
                break
            end
        end

        if #array_items > 0 then
            data[key] = array_items
        else
            data[key] = nil
        end

        i = j

        ::continue::
    end

    return data
end

local function yaml_get_property(filepath, property)
    local yaml = yaml_get(filepath)
    return yaml and yaml[property] or nil
end

------------------------------------------------------------------------------
-- UPDATE 'UPDATED' PROPERTY ON SAVE -----------------------------------------
------------------------------------------------------------------------------

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

------------------------------------------------------------------------------
-- HASHTAG PICKERS -----------------------------------------------------------
------------------------------------------------------------------------------

-- Helper function to search for a specific tag and show results
local function search_tag(tag)
    pick.builtin.cli(
        {
            command = {
                'rg', '--no-heading', '--with-filename',
                '--line-number', '--color=never',
                '(^|\\s)#' .. tag .. '(\\s|$|/)',
                '--glob', '*.md'
            },
            postprocess = function(lines)
                local results = {}
                local file_cache = {}

                for _, line in ipairs(lines) do
                    local filepath, line_num, content =
                        line:match('^([^:]+):(%d+):(.*)$')

                    if filepath and line_num and content then
                        if not file_cache[filepath] then
                            local updated = yaml_get_property(filepath,
                                                              'updated')
                            file_cache[filepath] = date_to_ts(updated) or 0
                        end

                        table.insert(results, {
                            path = filepath,
                            lnum = tonumber(line_num),
                            content = content,
                            timestamp = file_cache[filepath]
                        })
                    end
                end

                table.sort(results, function(a, b)
                    return a.timestamp > b.timestamp
                end)

                return results
            end
        },
        {
            source = {
                cwd = notes_dir,
                name = 'Tag: ' .. tag,
                show = function(buf_id, items, query)
                    local display_items = {}
                    for _, item in ipairs(items) do
                        table.insert(display_items,
                                     string.format('%s:%s:%s',
                                                   item.path,
                                                   item.lnum,
                                                   item.content))
                    end
                    return pick.default_show(buf_id, display_items, query,
                                             { show_icons = true })
                end,
            },
        }
    )
end

-- search for a hashtag
vim.keymap.set('n', '<leader>ng', function()
    vim.ui.input({ prompt = 'Tag: ' }, function(input)
        if input and input ~= '' then
            search_tag(input)
        end
    end)
end,
{ desc = '[N]otes Ta[G]s' })

-- Helper function to check if a tag is valid (not a number or color code)
local function is_valid_tag(tag)
    return not tag:match('^%d') and
           not tag:match('^%x%x%x%x%x%x$') and
           not tag:match('^%x%x%x%x%x%x%x%x$')
end

-- helper function to get code block line ranges for a file
local function get_codeblock_ranges(filepath)
    local file = io.open(filepath, 'r')
    if not file then
        return {}
    end

    local ranges = {}
    local in_block = false
    local block_start = nil
    local line_num = 1

    for line in file:lines() do
        if line:match('^```') then
            if in_block then
                -- End of code block
                table.insert(ranges,
                             { start = block_start, finish = line_num })
                in_block = false
                block_start = nil
            else
                -- Start of code block
                in_block = true
                block_start = line_num
            end
        end
        line_num = line_num + 1
    end

    file:close()
    return ranges
end

-- helper function to check if a line number is inside a code block
local function is_in_codeblock(line_num, ranges)
    for _, range in ipairs(ranges) do
        if line_num >= range.start and line_num <= range.finish then
            return true
        end
    end
    return false
end

-- list all hashtags and search for the selected one
vim.keymap.set('n', '<leader>ns', function()
    pick.builtin.cli(
        {
            command = {
                'rg', '--no-heading', '--with-filename',
                '--line-number', '--only-matching',
                '(^|\\s)#[\\w/-]+', '--glob', '*.md'
            },
            postprocess = function(lines)
                local tag_counts = {}
                local file_cache = {}

                for _, line in ipairs(lines) do
                    local filepath, line_num, match =
                        line:match('^([^:]+):(%d+):(.+)$')
                    local tag = match and match:match('#([%w/-]+)')

                    if filepath and line_num and tag and is_valid_tag(tag) then
                        line_num = tonumber(line_num)

                        if not file_cache[filepath] then
                            file_cache[filepath] =
                                get_codeblock_ranges(filepath)
                        end

                        if not is_in_codeblock(line_num,
                                               file_cache[filepath]) then
                            tag_counts[tag] = (tag_counts[tag] or 0) + 1
                        end
                    end
                end

                -- convert to array with counts and sort by tag name
                local tags = {}
                for tag, count in pairs(tag_counts) do
                    table.insert(tags, { tag = tag, count = count })
                end
                table.sort(tags, function(a, b) return a.tag < b.tag end)

                return tags
            end
        },
        {
            source = {
                cwd = notes_dir,
                name = 'All Hashtags',
                show = function(buf_id, items, query)
                    local display_items = {}
                    for _, item in ipairs(items) do
                        table.insert(display_items,
                                     string.format('%-20s (%d)', item.tag,
                                                   item.count))
                    end
                    return pick.default_show(buf_id, display_items, query,
                                             { show_icons = true })
                end,
                choose = function(item)
                    if item then
                        search_tag(item.tag)
                    end
                end
            },
        }
    )
end,
{ desc = '[N]otes Tag [S]earch' })

------------------------------------------------------------------------------
-- TASK PICKERS --------------------------------------------------------------
------------------------------------------------------------------------------

-- helper function to extract task type and date from content
local function extract_task_type_and_date(content)
    -- check for completion date first
    local date = content:match(PATTERNS.COMPLETION_TAG:format(PATTERNS.DATE))
    if date then
        return 'completion', date
    end
    -- next check for punted date
    date = content:match(PATTERNS.PUNTED_TAG:format(PATTERNS.DATE))
    if date then
        return 'punted', date
    end
    -- determine type by checkbox if no date found
    if content:match(PATTERNS.CHECKBOX_DONE) then
        return 'completion', nil
    elseif content:match(PATTERNS.CHECKBOX_PUNTED) then
        return 'punted', nil
    elseif content:match(PATTERNS.CHECKBOX_OPEN) then
        return 'open', nil
    end
    return nil, nil
end

-- helper function to create a task picker with sorting by a date/time
local function search_tasks(opts)
    local rg_pattern = opts.pattern
    local picker_name = opts.name

    -- optional function(task_ts) -> boolean
    local time_filter = opts.time_filter

    -- optional function(content) -> type, date
    local type_extractor = opts.type_extractor

    -- optional boolean: sort by task date instead of file timestamp
    local sort_by_task_date = opts.sort_by_task_date or false

    pick.builtin.cli(
        {
            command = {
                'rg', '--no-heading', '--line-number', '--color=never',
                rg_pattern, '--glob', '*.md'
            },
            postprocess = function(lines)
                local tasks = {}
                local file_cache = {}

                for _, line in ipairs(lines) do
                    local filepath, line_num, content =
                        line:match('^([^:]+):(%d+):(.*)$')
                    if filepath and content then
                        -- get file's updated timestamp and cache it
                        if not file_cache[filepath] then
                            local updated =
                                yaml_get_property(filepath, 'updated')
                            file_cache[filepath] = {
                                timestamp = date_to_ts(updated) or 0,
                                date_str = updated,
                            }
                        end

                        local task_type = nil
                        local task_date = nil

                        -- extract task type/date if extractor is provided
                        if type_extractor then
                            task_type, task_date = type_extractor(content)
                        end

                        -- apply time filter if provided
                        if time_filter then
                            local task_ts =
                                task_date and date_to_ts(task_date)
                            if not task_ts or not time_filter(task_ts) then
                                goto continue
                            end
                        end

                        -- determine which timestamp to use for sorting
                        local sort_timestamp = file_cache[filepath].timestamp
                        if sort_by_task_date and task_date then
                            sort_timestamp =
                                date_to_ts(task_date) or sort_timestamp
                        end

                        -- determine which date string to display
                        local display_date =
                            task_date or file_cache[filepath].date_str

                        -- strip time component if present
                        if display_date then
                            display_date =
                                display_date:match('^(%d%d%d%d%-%d%d%-%d%d)')
                                or display_date
                        end

                        table.insert(tasks, {
                            path = filepath,
                            lnum = tonumber(line_num),
                            content = content:gsub('^%s+', ''),
                            timestamp = sort_timestamp,
                            type = task_type,
                            date = task_date,
                            display_date = display_date,
                        })

                        ::continue::
                    end
                end

                -- Sort by timestamp (newest first)
                table.sort(tasks, function(a, b)
                    return a.timestamp > b.timestamp
                end)

                return tasks
            end
        },
        {
            source = {
                name = picker_name,
                cwd = notes_dir,
                show = function(buf_id, items, query)
                    local display_items = {}

                    for _, item in ipairs(items) do
                        local type_label = 'o'
                        if item.type == 'completion' then
                            type_label = '✓'
                        elseif item.type == 'punted' then
                            type_label = '→'
                        end

                        table.insert(display_items,
                                     string.format('%s %s | %s:%s | %s',
                                                   type_label,
                                                   item.display_date or '',
                                                   item.path,
                                                   item.lnum,
                                                   item.content))
                    end

                    return pick.default_show(buf_id, display_items, query,
                                             { show_icons = true })
                end
                -- match = function(stritems, inds, query)
                --     return pick.default_match(stritems, inds, query,
                --                               { sync = true,
                --                                 preserve_order = true })
                -- end
            },
        }
    )
end

-- search for all tasks
vim.keymap.set('n', '<leader>nta', function()
    search_tasks({
        pattern = [[^\s*- \[ \] |^\s*- \[x\] |^\s*- \[-\] ]],
        name = 'All Tasks',
        sort_by_task_date = true,
        type_extractor = extract_task_type_and_date,
    })
end,
{ desc = '[N]otes [T]asks [A]ll' })

-- search for open tasks
vim.keymap.set('n', '<leader>nto', function()
    search_tasks({
        pattern = [[^\s*- \[ \] ]],
        name = 'Open Tasks',
    })
end,
{ desc = '[N]otes [T]asks [O]pen' })

-- search for completed tasks
vim.keymap.set('n', '<leader>ntc', function()
    search_tasks({
        pattern = [[^\s*- \[x\] ]],
        name = 'Completed Tasks',
        sort_by_task_date = true,
        type_extractor = extract_task_type_and_date,
    })
end,
{ desc = '[N]otes [T]asks [C]ompleted' })

-- search for punted tasks
vim.keymap.set('n', '<leader>ntp', function()
    search_tasks({
        pattern = [[^\s*- \[-\] ]],
        name = 'Punted Tasks',
        sort_by_task_date = true,
        type_extractor = extract_task_type_and_date,
    })
end,
{ desc = '[N]otes [T]asks [P]unted' })

-- search for completed or punted tasks from the past 6 months
vim.keymap.set('n', '<leader>ntr', function()
    local one_month_ago = os.time() - (6 * 30 * 24 * 60 * 60)

    search_tasks({
        pattern = [[^\s*- \[x\] |^\s*- \[-\] ]],
        name = 'Recent Completed/Punted Tasks (Past 6 Months)',
        sort_by_task_date = true,
        type_extractor = extract_task_type_and_date,
        time_filter = function(task_ts)
            -- only filter if we have a task timestamp
            -- if task_ts is nil, it means no date was found, so we keep it
            return task_ts == nil or task_ts >= one_month_ago
        end,
    })
end,
{ desc = '[N]otes [T]asks [R]ecent (Past 6 Months)' })

------------------------------------------------------------------------------
-- TOGGLE DATAVIEW TAGS ------------------------------------------------------
------------------------------------------------------------------------------

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

-- factory function to create tag togglers
local function create_dataview_tag_toggler(tag_type)
    return function()
        local tag = string.format('[%s:: %s]', tag_type, os.date('%Y-%m-%d'))
        local tag_pattern = string.format('%%[%s:: %s%%]$', tag_type, PATTERNS.DATE)
        toggle_dataview_tag(tag, tag_pattern)
    end
end

-- toggle completion
vim.keymap.set('n', '<leader>nc', create_dataview_tag_toggler('completion'),
    { desc = '[N]otes [C]omplete Task' })

-- toggle punted
vim.keymap.set('n', '<leader>np', create_dataview_tag_toggler('punted'),
    { desc = '[N]otes [P]unt Task' })

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

vim.keymap.set('n', '<leader>jdd', '<Cmd>Journal<CR>',
               { desc = '[J]ournal [D]ay To[D]ay' })
vim.keymap.set('n', '<leader>jdp', '<Cmd>Journal -1<CR>',
               { desc = '[J]ournal [D]ay [P]rev' })
vim.keymap.set('n', '<leader>jdn', '<Cmd>Journal +1<CR>',
               { desc = '[J]ournal [D]ay [N]ext' })

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

-- in "YYYY-wWW", out { sunday_date_long, sunday_date, saturday_date }
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

vim.keymap.set('n', '<leader>jww', '<Cmd>JournalWeek<CR>',
               { desc = '[J]ournal [W]eek [W]eek' })
vim.keymap.set('n', '<leader>jwp', '<Cmd>JournalWeek -1<CR>',
               { desc = '[J]ournal [W]eek [P]rev' })
vim.keymap.set('n', '<leader>jwn', '<Cmd>JournalWeek +1<CR>',
               { desc = '[J]ournal [W]eek [N]ext' })

------------------------------------------------------------------------------
-- JOURNAL ENTRIES MISSING ---------------------------------------------------
------------------------------------------------------------------------------

-- journal missing days command
vim.api.nvim_create_user_command('JournalMissing', function()
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
end, { desc = 'List missing journal entries', nargs = '?' })

-- journal missing weeks command
vim.api.nvim_create_user_command('JournalWeekMissing', function()
    local missing_weeks = {}
    local date_t = os.time()

    for i = 0, 52 do
        local tmp_date_t = (date_t - (i * 608400)) -- subtract i weeks

        local tmp_date_str = os.date('%Y-%m-%d', tmp_date_t)
        local year, week = date_to_week(tmp_date_str)

        local journal_week_file = journal_week_path(year, week)

        if vim.fn.filereadable(journal_week_file) == 0 then
            missing_weeks[#missing_weeks + 1] = { year = year, week = week }
        end
    end

    local week = pick.start({
        source = {
            name = 'Missing Journal Week Entries',
            items = missing_weeks,
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
end, { desc = 'List missing journal week entries', nargs = '?' })

vim.keymap.set('n', '<leader>jdm', '<Cmd>JournalMissing<CR>',
               { desc = '[J]ournal [D]ay [M]issing' })
vim.keymap.set('n', '<leader>jwm', '<Cmd>JournalWeekMissing<CR>',
               { desc = '[J]ournal [W]eek [M]issing' })

------------------------------------------------------------------------------
-- READING LIST PICKER -------------------------------------------------------
------------------------------------------------------------------------------

-- FIXME
-- This could be simplified by simply parsing the PDFs/_pdf_*.txt files
-- created by the 'pdf_gen_lists' script.

pick.registry.reading_list = function(local_opts)
    return pick.builtin.cli(
        {
            command = {
                'fd', '-e', 'md',
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
                        p_value = yaml_get_property(line, p_name)
                    else
                        -- this is the 'todo' type
                        if not yaml_get_property(line, 'completion') and
                           not yaml_get_property(line, 'punted') then
                            p_value = yaml_get_property(line, 'created')
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
                    return date_to_ts(a.date) > date_to_ts(b.date)
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

vim.keymap.set('n', '<leader>nra', function()
    pick.registry.reading_list({
        dir = 'PDFs',
        type = 'all',
    })
end,
{ desc = '[N]otes [R]ead [A]ll' })

vim.keymap.set('n', '<leader>nrt', function()
    pick.registry.reading_list({
        dir = 'PDFs',
        type = 'todo',
    })
end,
{ desc = '[N]otes [R]ead [T]odo' })

vim.keymap.set('n', '<leader>nrc', function()
    pick.registry.reading_list({
        dir = 'PDFs',
        type = 'completed',
    })
end,
{ desc = '[N]otes [R]ead [C]ompleted' })

vim.keymap.set('n', '<leader>nrp', function()
    pick.registry.reading_list({
        dir = 'PDFs',
        type = 'punted',
    })
end,
{ desc = '[N]otes [R]ead [P]unted' })

------------------------------------------------------------------------------
-- FILE TAG MANAGEMENT -------------------------------------------------------
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
               { desc = '[M]arkdown [T]ag [A]dd to file' })
vim.keymap.set('n', '<leader>mtr', tag_remove,
               { desc = '[M]arkdown [T]ag [R]emove from file' })

------------------------------------------------------------------------------
-- RECENT FILES --------------------------------------------------------------
------------------------------------------------------------------------------

pick.registry.recent_files = function(local_opts)
    return pick.builtin.cli(
        {
            command = {
                'fd', '-e', 'md',
            },
            postprocess = function(items)
                local files = {}

                -- process each file getting the last modified date
                for _, filepath in ipairs(items) do
                    local date = nil

                    for _, exclude in ipairs(local_opts.exclude or {}) do
                        if string.match(filepath, exclude) then
                            goto continue
                        end
                    end

                    -- try to extract the date from the yaml
                    local yaml = yaml_get(filepath)
                    if yaml then
                        if yaml.updated then
                            date = date_to_ts(yaml.updated)
                        elseif yaml.created then
                            date = date_to_ts(yaml.created)
                        end
                    end

                    -- fallback to file modification time
                    if not date then
                        date = get_file_mtime(filepath)
                    end

                    table.insert(files, {
                        path = filepath,
                        timestamp = date,
                    })

                    ::continue::
                end

                -- sort by timestamp (newest first)
                table.sort(files, function(a, b)
                    return a.timestamp > b.timestamp
                end)

                return files
            end,
        },
        {
            source = {
                cwd = notes_dir,
                name = 'Recent Notes',
                show = function(buf_id, items, query)
                    local display_items = {}
                    for _, item in ipairs(items) do
                        table.insert(display_items,
                                     string.format('%s | %s',
                                                   os.date('%Y-%m-%d',
                                                           item.timestamp),
                                                   item.path))
                    end
                    return pick.default_show(buf_id, display_items, query,
                                             { show_icons = true })
                end,
            },
        }
    )
end

vim.keymap.set('n', '<leader>nR', function()
    pick.registry.recent_files({
        exclude = { 'Journal', 'templates', },
    })
end,
{ desc = '[N]otes [R]ecent' })

------------------------------------------------------------------------------
-- OPEN PDF FROM FILE LINK ---------------------------------------------------
------------------------------------------------------------------------------

local pdf_dir = notes_dir .. '/PDFs/'

local function run_pdf_expert(file_path)
    vim.notify('Opening "' .. file_path .. '"', vim.log.levels.INFO)
    vim.system({ 'open', file_path }, function()
        vim.notify('Done editing "' .. file_path .. '"', vim.log.levels.INFO)
    end)
end

vim.keymap.set('n', '<leader>nP', function()
    local file = vim.fn.expand('<cfile>:t')
    if not string.match(file, '%.pdf$') then
        vim.notify('PDF only', vim.log.levels.ERROR)
        return
    end

    local file_path = pdf_dir .. file

    if vim.fn.filereadable(file_path) == 0 then
        vim.notify('PDF doesn\'t exist', vim.log.levels.ERROR)
        return
    end

    confirm_and_run('Open "' .. file .. '"', function()
        run_pdf_expert(file_path)
    end)
end,
{ desc = '[N]otes [P]DF Expert' })

------------------------------------------------------------------------------
-- EDIT IMAGE IN EXCALIDRAW --------------------------------------------------
------------------------------------------------------------------------------

local assets_dir = notes_dir .. '/assets/'
local excli_blank = assets_dir .. 'blank.excalidraw'

local function run_excalidraw(efile_path)
    if vim.fn.filereadable(efile_path) == 0 then
        if vim.fn.filereadable(excli_blank) == 0 then
            vim.notify('Blank Excalidraw file not found',
                       vim.log.levels.ERROR)
            return
        end

        vim.system({ 'cp', '-f', excli_blank, efile_path }):wait()
    end

    vim.notify('Opening "' .. efile_path .. '"', vim.log.levels.INFO)
    vim.system({ 'excli', efile_path }, function()
        vim.notify('Done editing "' .. efile_path .. '"', vim.log.levels.INFO)
    end)
end

vim.keymap.set('n', '<leader>nx', function()
    local file = vim.fn.expand('<cfile>')
    if not string.match(file, '%.excalidraw.png$') then
        vim.notify('Excalidraw/PNG only', vim.log.levels.ERROR)
        return
    end

    local efile = string.gsub(file, '^(.+).png$', '%1')

    local file_path = assets_dir .. file
    local efile_path = assets_dir .. efile

    local prompt = 'Edit "' .. efile .. '"'
    if vim.fn.filereadable(file_path) == 0 then
        prompt = 'Create and ' .. prompt
    end

    confirm_and_run(prompt, function()
        run_excalidraw(efile_path)
    end)
end,
{ desc = '[N]otes E[X]calidraw' })

------------------------------------------------------------------------------
-- MARKDOWN TABLE UTILITIES --------------------------------------------------
------------------------------------------------------------------------------

local function clear_table_except_first_column()
    local start_row = vim.fn.line("'<")
    local end_row = vim.fn.line("'>")

    local lines = vim.api.nvim_buf_get_lines(0, start_row - 1, end_row, false)
    local new_lines = {}

    for _, line in ipairs(lines) do
        if not line:match('^%s*|') then
            table.insert(new_lines, line)
            goto SKIP
        end

        local pipe_positions = {}
        local i = 1
        while i <= #line do
            if line:sub(i, i) == '|' then
                table.insert(pipe_positions, i)
            end
            i = i + 1
        end

        if #pipe_positions < 2 then
            table.insert(new_lines, line)
            goto SKIP
        end

        local new_line = line

        for j = 2, #pipe_positions - 1 do
            local start_pos = pipe_positions[j] + 1
            local end_pos = pipe_positions[j + 1] - 1

            local spaces = string.rep(' ', end_pos - start_pos + 1)
            new_line = new_line:sub(1, start_pos - 1) .. spaces ..
                       new_line:sub(end_pos + 1)
        end

        table.insert(new_lines, new_line)

        ::SKIP::
    end

    vim.api.nvim_buf_set_lines(0, start_row - 1, end_row, false, new_lines)
end

vim.api.nvim_create_user_command(
    'ClearTableCells', clear_table_except_first_column, {
    range = true,
    desc = 'Clear all table cells except first column in visual selection'
})

------------------------------------------------------------------------------
-- RANDOM NOTE ---------------------------------------------------------------
------------------------------------------------------------------------------

vim.keymap.set('n', '<leader>nd', function()
    pick.builtin.cli(
        {
            command = {
                'fd', '-e', 'md',
                '--exclude', 'Journal',
                '--exclude', 'PDFs',
                '--exclude', 'libfabric',
                '--exclude', 'templates',
                '--exclude', 'templates_nvim',
            },
            postprocess = function(items)
                if #items == 0 then
                    vim.notify('No markdown files found', vim.log.levels.WARN)
                    return {}
                end

                math.randomseed(os.time())
                local random_index = math.random(1, #items)
                return { items[random_index] }
            end
        },
        {
            source = {
                cwd = notes_dir,
                name = 'Random Note',
            },
        }
    )
end,
{ desc = '[N]otes Ran[D]om' })

------------------------------------------------------------------------------
-- RANDOM QUOTE --------------------------------------------------------------
------------------------------------------------------------------------------

local function get_random_stoicism_quote()
    local stoicism_file = notes_dir .. '/snips/stoicism_quotes.json'

    -- use jq to get a random quote (pipe-delimited format)
    -- first run to get the count, second run to select random index
    local cmd = string.format(
        [[
            bash -c 'INDEX=$(jq ".quotes | length" %s);
            INDEX=$((RANDOM %% INDEX));
            jq -r ".quotes[$INDEX] | .text + \"|\" + .author" %s'
        ]],
        vim.fn.shellescape(stoicism_file),
        vim.fn.shellescape(stoicism_file)
    )

    local handle = io.popen(cmd)
    if not handle then
        return nil
    end

    local result = handle:read('*all')
    handle:close()

    if not result or result == '' then
        return nil
    end

    -- parse the pipe-delimited result and strip whitespace
    local text, author = result:match('^(.-)%s*|%s*(.-)%s*$')
    if text and author then
        return { text = text, author = author }
    end

    return nil
end

local function get_random_quote_md()
    local quotes_file = notes_dir .. '/Quotes.md'
    local file = io.open(quotes_file, 'r')
    if not file then
        return nil
    end

    local quotes = {}
    for line in file:lines() do
        -- match lines that start with '- ' (bullet points)
        local quote = line:match('^%s*-%s*(.+)$')
        if quote then
            -- remove == emphasis markers if present
            quote = quote:gsub('==(.+)==', '%1')
            table.insert(quotes, quote)
        end
    end
    file:close()

    if #quotes == 0 then
        return nil
    end

    math.randomseed(os.time())
    local random_index = math.random(1, #quotes)
    return quotes[random_index]
end

vim.keymap.set('n', '<leader>nq', function()
    local stoicism_quote = get_random_stoicism_quote()
    local md_quote = get_random_quote_md()

    if not stoicism_quote and not md_quote then
        vim.notify('No quotes found', vim.log.levels.ERROR)
        return
    end

    local lines = {}

    table.insert(lines, '')

    if stoicism_quote then
        table.insert(lines, 'STOICISM QUOTE')
        table.insert(lines, '')
        table.insert(lines, stoicism_quote.text)
        table.insert(lines, '    - ' .. stoicism_quote.author)
        table.insert(lines, '')
    end

    if md_quote then
        table.insert(lines, 'PERSONAL QUOTE')
        table.insert(lines, '')
        table.insert(lines, md_quote)
    end

    table.insert(lines, '')

    -- create a new floating window
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)
    vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')

    -- calculate window size to fit all content
    local width = 70
    -- calculate actual visual height accounting for wrapped lines
    local visual_height = 0
    for _, line in ipairs(lines) do
        local line_length = vim.fn.strdisplaywidth(line)
        -- calculate how many wrapped lines this will take (at least 1)
        visual_height =
            visual_height + math.max(1, math.ceil(line_length / width))
    end

    local max_height = math.floor(vim.o.lines * 0.8) -- 80% of screen height
    local height = math.min(visual_height, max_height)

    local win_opts = {
        relative = 'editor',
        width = width,
        height = height,
        col = (vim.o.columns - width) / 2,
        row = math.floor((vim.o.lines - height) / 2),
        style = 'minimal',
        border = 'rounded',
    }

    local win = vim.api.nvim_open_win(buf, true, win_opts)

    -- set wrap and linebreak for better text display
    vim.api.nvim_win_set_option(win, 'wrap', true)
    vim.api.nvim_win_set_option(win, 'linebreak', true)

    -- close with 'q' or ESC
    local close_win = function()
        vim.api.nvim_win_close(win, true)
    end
    vim.keymap.set('n', 'q', close_win, { buffer = buf, noremap = true })
    vim.keymap.set('n', '<Esc>', close_win, { buffer = buf, noremap = true })
end,
{ desc = '[N]otes Random [Q]uote' })

------------------------------------------------------------------------------
-- KEYMAP HELP ---------------------------------------------------------------
------------------------------------------------------------------------------

-- New picker that lists all the notes keymaps (help!)
local notes_help = {
    '<leader>nh                         Notes Keymap Help',
    '',
    '<leader>sf                         All Files',
    '<leader>nr                         Recent Notes',
    '',
    '<leader>nd                         Random Note',
    '<leader>nq                         Random Quote',
    '',
    '<leader>ng                         Search for Tag',
    '<leader>ns                         Select Tag and Search',
    '',
    '<leader>nto                        Search Open Tasks',
    '<leader>ntc                        Search Completed Tasks',
    '<leader>ntp                        Search Punted Tasks',
    '<leader>ntr                        Search Recent Tasks (Past Month)',
    '',
    '<leader>nc                         Toggle Task Completed',
    '<leader>np                         Toggle Task Punted',
    '',
    '<leader>nx                         Open image under cursor (Excalidraw)',
    '<leader>nP                         Open PDF under cursor (PDF Expert)',
    '',
    '<leader>jdd  :Journal [+/-N]       Journal Day',
    '<leader>jdp  :Journal -1           Journal Previous Day',
    '<leader>jdn  :Journal +1           Journal Next Day',
    '',
    '<leader>jww  :JournalWeek [+/-N]   Journal Week',
    '<leader>jwp  :JournalWeek -1       Journal Previous Week',
    '<leader>jwn  :JournalWeek +1       Journal Next Week',
    '',
    '<leader>jdm  :JournalMissing       Missing Journal Days',
    '<leader>jwm  :JournalWeekMissing   Missing Journal Week Days',
    '',
    '<leader>nra                        Reading List All',
    '<leader>nrt                        Reading List Todo',
    '<leader>nrc                        Reading list Completed',
    '<leader>nrp                        Reading List Punted',
    '',
    ' --> LSP integration <--',
    '',
    '<leader>K[K]                       Hover show file link',
    '<leader>ld                         Follow file link',
    '<leader>lr                         Find all backlinks of current file',
    '<leader>lr                         Find all backlinks for file link',
    '<leader>lr                         Tag find all occurrences',
    '<leader>ls                         List all headings',
    '<leader>lR                         Rename file',
    '<leader>lR                         Tag rename across all files',
    ':lua vim.lsp.buf.code_action()     Create file for unresolved link',
    '',
    'gf                                 Follow file link',
    '',
    ' --> Markdown commands <--',
    '',
    '<leader>mta                        Markdown Tag Add',
    '<leader>mtr                        Markdown Tag Remove',
    '<leader>m<...>                     markdown-plus plugin commands',
    '',
    '\'<,\'>ClearTableCells               Clear table cells (visual selection)',
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

vim.keymap.set('n', '<leader>nh', function()
    pick.registry.notes_help()
end,
{ desc = '[N]otes [H]elp' })

