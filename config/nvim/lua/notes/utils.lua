-- Generic utility functions used across the notes system

local M = {}

-- Helper function for y/n confirmation before executing an action
function M.confirm_and_run(prompt, action)
    vim.ui.input({ prompt = prompt .. ' (y/n): '}, function(input)
        if input == 'y' or input == 'yes' then
            action()
        end
    end)
end

-- Get file modification time
function M.get_file_mtime(filepath)
    local stat = vim.uv.fs_stat(filepath)
    return stat and stat.mtime.sec or 0
end

-- Helper function to get code block line ranges for a file
function M.get_codeblock_ranges(filepath)
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
function M.is_in_codeblock(line_num, ranges)
    for _, range in ipairs(ranges) do
        if line_num >= range.start and line_num <= range.finish then
            return true
        end
    end
    return false
end

return M
