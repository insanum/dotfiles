-- Task management: searching, filtering, and toggling task states

local config = require('notes.config')
local yaml = require('notes.yaml')
local pick = require('mini.pick')

local M = {}

-- Helper function to extract task type and date from content
local function extract_task_type_and_date(content)
    -- check for completion date first
    local date = content:match(config.PATTERNS.COMPLETION_TAG:format(config.PATTERNS.DATE))
    if date then
        return 'completion', date
    end
    -- next check for punted date
    date = content:match(config.PATTERNS.PUNTED_TAG:format(config.PATTERNS.DATE))
    if date then
        return 'punted', date
    end
    -- determine type by checkbox if no date found
    if content:match(config.PATTERNS.CHECKBOX_DONE) then
        return 'completion', nil
    elseif content:match(config.PATTERNS.CHECKBOX_PUNTED) then
        return 'punted', nil
    elseif content:match(config.PATTERNS.CHECKBOX_OPEN) then
        return 'open', nil
    end
    return nil, nil
end

-- Helper function to create a task picker with sorting by a date/time
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
                                yaml.get_property(filepath, 'updated')
                            file_cache[filepath] = {
                                timestamp = yaml.date_to_ts(updated) or 0,
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
                                task_date and yaml.date_to_ts(task_date)
                            if not task_ts or not time_filter(task_ts) then
                                goto continue
                            end
                        end

                        -- determine which timestamp to use for sorting
                        local sort_timestamp = file_cache[filepath].timestamp
                        if sort_by_task_date and task_date then
                            sort_timestamp =
                                yaml.date_to_ts(task_date) or sort_timestamp
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
                cwd = config.notes_dir,
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
            },
        }
    )
end

-- Search for all tasks
function M.search_all()
    search_tasks({
        pattern = [[^\s*- \[ \] |^\s*- \[x\] |^\s*- \[-\] ]],
        name = 'All Tasks',
        sort_by_task_date = true,
        type_extractor = extract_task_type_and_date,
    })
end

-- Search for open tasks
function M.search_open()
    search_tasks({
        pattern = [[^\s*- \[ \] ]],
        name = 'Open Tasks',
    })
end

-- Search for completed tasks
function M.search_completed()
    search_tasks({
        pattern = [[^\s*- \[x\] ]],
        name = 'Completed Tasks',
        sort_by_task_date = true,
        type_extractor = extract_task_type_and_date,
    })
end

-- Search for punted tasks
function M.search_punted()
    search_tasks({
        pattern = [[^\s*- \[-\] ]],
        name = 'Punted Tasks',
        sort_by_task_date = true,
        type_extractor = extract_task_type_and_date,
    })
end

-- Search for completed or punted tasks from the past 6 months
function M.search_recent()
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
end

-- Helper function to toggle a dataview tag on the current line
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

-- Factory function to create tag togglers
local function create_dataview_tag_toggler(tag_type)
    return function()
        local tag = string.format('[%s:: %s]', tag_type, os.date('%Y-%m-%d'))
        local tag_pattern = string.format('%%[%s:: %s%%]$', tag_type, config.PATTERNS.DATE)
        toggle_dataview_tag(tag, tag_pattern)
    end
end

-- Toggle completion tag on current line
function M.toggle_completion()
    create_dataview_tag_toggler('completion')()
end

-- Toggle punted tag on current line
function M.toggle_punted()
    create_dataview_tag_toggler('punted')()
end

return M
