-- Generic utility functions used across the notes system

local M = {}

-- Convert ISO date string to timestamp
function M.utils_date_to_ts(date_str)
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

-- Helper function for y/n confirmation before executing an action
function M.utils_confirm_and_run(prompt, action)
    vim.ui.input({ prompt = prompt .. ' (y/n): '}, function(input)
        if input == 'y' or input == 'yes' then
            action()
        end
    end)
end

-- Get file modification time
function M.utils_get_file_mtime(filepath)
    local stat = vim.uv.fs_stat(filepath)
    return stat and stat.mtime.sec or 0
end

-- Helper function to get code block line ranges for a file
function M.utils_get_codeblock_ranges(filepath)
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

-- Helper function to check if a line number is inside a code block
function M.utils_is_in_codeblock(line_num, ranges)
    for _, range in ipairs(ranges) do
        if line_num >= range.start and line_num <= range.finish then
            return true
        end
    end
    return false
end

return M
