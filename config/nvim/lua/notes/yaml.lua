-- YAML frontmatter parsing and manipulation utilities

local M = {}

-- Parse YAML frontmatter from a file
function M.yaml_get(filepath)
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

-- Get a specific property from YAML frontmatter
function M.yaml_get_property(filepath, property)
    local yaml = M.yaml_get(filepath)
    return yaml and yaml[property] or nil
end

-- Returns the start/end line index of the yaml frontmatter
-- These values are 0-based (end index is exclusive), for nvim_buf_get_lines
-- Range does NOT include the '---' lines
local function get_bounds()
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

-- Returns yaml start/end, list of tags, and tags start/end line indices
-- All values are 0-based (end index is exclusive), for nvim_buf_get_lines
function M.yaml_get_tags()
    local yaml_start, yaml_end = get_bounds()
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

-- Auto-update YAML frontmatter on save
-- Register autocmd for YAML frontmatter auto-update
vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
    pattern = '*.md',
    callback = function()
        local bufnr = vim.api.nvim_get_current_buf()

        -- bail if buffer hasn't been modified
        if not vim.api.nvim_get_option_value('modified', { buf = bufnr }) then
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

        -- attribute found flags
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

return M
