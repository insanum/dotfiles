-- Hashtag searching and file tag management for markdown notes

local config = require('notes.config')
local pick   = require('mini.pick')
local utils  = require('notes.utils')
local yaml   = require('notes.yaml')

-- Resolve a (possibly relative) picker path to an absolute path so file reads
-- don't depend on Neovim's current working directory
local function abs(filepath)
    if filepath:sub(1, 1) == '/' then
        return filepath
    end
    return config.notes_dir .. '/' .. filepath
end

-- List md files that declare a YAML 'tags:' property. Pre-filtering with rg
-- keeps this cheap -- only these files need their frontmatter parsed.
local function files_with_yaml_tags()
    return vim.fn.systemlist({
        'rg', '-l', '--glob', '*.md', '--color=never',
        '-e', '^tags:',
        config.notes_dir,
    })
end

-- YAML tags declared by a file, as a list
local function yaml_tags_of(filepath)
    local data = yaml.yaml_get(abs(filepath))
    local tags = data and data.tags
    if type(tags) == 'table' then
        return tags
    elseif type(tags) == 'string' then
        return { tags }
    end
    return {}
end

-- Line number of a specific tag entry inside the YAML frontmatter (1 if absent)
local function yaml_tag_lnum(filepath, tag)
    local file = io.open(abs(filepath), 'r')
    if not file then
        return 1
    end

    local lnum, in_fm, in_tags = 0, false, false
    for line in file:lines() do
        lnum = lnum + 1
        if lnum == 1 then
            if line ~= '---' then break end
            in_fm = true
        elseif in_fm and line == '---' then
            break
        elseif in_fm then
            if line:match('^tags:') then
                in_tags = true
            elseif in_tags then
                local t = line:match('^%s*-%s*(.+)$')
                if t then
                    if t:gsub('%s+$', '') == tag then
                        file:close()
                        return lnum
                    end
                else
                    in_tags = false
                end
            end
        end
    end

    file:close()
    return 1
end

-- Helper function to check if a tag is valid (not a number or color code)
local function is_valid_tag(tag)
    return not tag:match('^%d') and
           not tag:match('^%x%x%x%x%x%x$') and
           not tag:match('^%x%x%x%x%x%x%x%x$')
end

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
                local cb_cache = {}
                local seen = {}

                local function timestamp_of(filepath)
                    if not file_cache[filepath] then
                        local updated =
                            yaml.yaml_get_property(abs(filepath), 'updated')
                        file_cache[filepath] =
                            utils.utils_date_to_ts(updated) or 0
                    end
                    return file_cache[filepath]
                end

                -- inline hashtags in the body
                for _, line in ipairs(lines) do
                    local filepath, line_num, content =
                        line:match('^([^:]+):(%d+):(.*)$')

                    if filepath and line_num and content then
                        line_num = tonumber(line_num)

                        -- a tag inside a fenced code block is code, not a tag
                        if not cb_cache[filepath] then
                            cb_cache[filepath] =
                                utils.utils_get_codeblock_ranges(abs(filepath))
                        end

                        if not utils.utils_is_in_codeblock(line_num,
                                                           cb_cache[filepath]) then
                            seen[filepath] = true
                            table.insert(results, {
                                path = filepath,
                                lnum = line_num,
                                content = content,
                                timestamp = timestamp_of(filepath),
                            })
                        end
                    end
                end

                -- tags declared in YAML frontmatter (invisible to the rg scan
                -- above, since frontmatter entries carry no '#')
                for _, filepath in ipairs(files_with_yaml_tags()) do
                    for _, t in ipairs(yaml_tags_of(filepath)) do
                        if t == tag then
                            local rel = filepath:gsub(
                                '^' .. vim.pesc(config.notes_dir) .. '/', '')
                            table.insert(results, {
                                path = rel,
                                lnum = yaml_tag_lnum(filepath, tag),
                                content = 'tags: ' .. tag,
                                timestamp = timestamp_of(rel),
                            })
                            break
                        end
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
                cwd = config.notes_dir,
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

-- Search for a hashtag (user input)
local function search()
    vim.ui.input({ prompt = 'Tag: ' }, function(input)
        if input and input ~= '' then
            search_tag(input)
        end
    end)
end

-- List all hashtags and search for the selected one
local function select_and_search()
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
                                utils.utils_get_codeblock_ranges(abs(filepath))
                        end

                        if not utils.utils_is_in_codeblock(line_num,
                                                           file_cache[filepath]) then
                            tag_counts[tag] = (tag_counts[tag] or 0) + 1
                        end
                    end
                end

                -- tags declared in YAML frontmatter, which the rg scan
                -- above cannot see (frontmatter entries carry no '#')
                for _, filepath in ipairs(files_with_yaml_tags()) do
                    for _, t in ipairs(yaml_tags_of(filepath)) do
                        if is_valid_tag(t) then
                            tag_counts[t] = (tag_counts[t] or 0) + 1
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
                cwd = config.notes_dir,
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
end

-- Add a tag to current file's YAML frontmatter
local function add_to_file()
    if vim.bo.filetype ~= 'markdown' then
        vim.notify('Markdown files only', vim.log.levels.WARN)
        return
    end

    vim.ui.input({ prompt = 'Enter tag to add: ' }, function(tag)
        if not tag or tag == '' then
            return
        end

        tag = tag:gsub('^%s*', ''):gsub('%s*$', '')

        local yaml_start, yaml_end, tags, _, tags_end = yaml.yaml_get_tags()

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

-- Remove a tag from current file's YAML frontmatter
local function remove_from_file()
    if vim.bo.filetype ~= 'markdown' then
        vim.notify('Markdown files only', vim.log.levels.WARN)
        return
    end

    local yaml_start, yaml_end, tags, _, _ = yaml.yaml_get_tags()

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

-- register commands

vim.api.nvim_create_user_command('NotesTagSearch', search,
    { desc = 'Search for a specific hashtag' })

vim.api.nvim_create_user_command('NotesTagSelect', select_and_search,
    { desc = 'Select a hashtag and search' })

vim.api.nvim_create_user_command('NotesTagAdd', add_to_file,
    { desc = 'Add a tag to current file YAML frontmatter' })

vim.api.nvim_create_user_command('NotesTagRemove', remove_from_file,
    { desc = 'Remove a tag from current file YAML frontmatter' })

