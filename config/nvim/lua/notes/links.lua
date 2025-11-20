-- Broken link checker for wiki-style markdown links

local config = require('notes.config')
local utils = require('notes.utils')
local pick = require('mini.pick')

local M = {}

-- Helper function to build file cache for link checking
local function build_file_cache()
    local cache = {}
    local files = vim.fn.systemlist(
        string.format('find %s -type f', vim.fn.shellescape(config.notes_dir))
    )

    for _, fpath in ipairs(files) do
        local relpath = fpath:gsub('^' .. vim.pesc(config.notes_dir) .. '/', '')
        local basename = vim.fn.fnamemodify(fpath, ':t')

        -- store by basename and relpath (lowercase for case-insensitive)
        cache[basename:lower()] = true
        cache[relpath:lower()] = true

        -- for .md files, also store without extension
        if relpath:match('%.md$') then
            cache[relpath:gsub('%.md$', ''):lower()] = true
            cache[basename:gsub('%.md$', ''):lower()] = true
        end
    end

    return cache
end

-- Helper function to extract clean link target from [[...]]
local function extract_link_target(link)
    -- strip alias: [[file|alias]] -> file
    local target = link:match('^([^|]+)') or link
    -- strip heading: [[file#heading]] -> file
    target = target:match('^([^#]+)') or target
    -- trim whitespace
    return target:gsub('^%s*(.-)%s*$', '%1')
end

-- Find all broken links in notes
function M.find()
    pick.builtin.cli(
        {
            command = {
                'rg', '--no-heading', '--line-number', '--color=never',
                '\\[\\[[^]]+\\]\\]', '--glob', '*.md'
            },
            postprocess = function(lines)
                local broken_links = {}
                local file_cache = build_file_cache()
                local codeblock_cache = {}

                for _, line in ipairs(lines) do
                    local filepath, line_num, content =
                        line:match('^([^:]+):(%d+):(.*)$')

                    if not filepath then goto continue_line end

                    line_num = tonumber(line_num)

                    -- skip code blocks
                    if not codeblock_cache[filepath] then
                        codeblock_cache[filepath] =
                            utils.get_codeblock_ranges(filepath)
                    end
                    if utils.is_in_codeblock(line_num,
                                       codeblock_cache[filepath]) then
                        goto continue_line
                    end

                    -- check each link on the line
                    for link in content:gmatch('%[%[([^%]]+)%]%]') do
                        local target = extract_link_target(link)

                        if target ~= '' and not file_cache[target:lower()] then
                            table.insert(broken_links, {
                                path = filepath,
                                lnum = line_num,
                                link = link,
                            })
                        end
                    end

                    ::continue_line::
                end

                return broken_links
            end
        },
        {
            source = {
                cwd = config.notes_dir,
                name = 'Broken Links',
                show = function(buf_id, items, query)
                    local display_items = {}
                    for _, item in ipairs(items) do
                        table.insert(display_items,
                                     string.format('%s:%s | [[%s]]',
                                                   item.path,
                                                   item.lnum,
                                                   item.link))
                    end
                    return pick.default_show(buf_id, display_items, query,
                                             { show_icons = true })
                end,
            },
        }
    )
end

return M
