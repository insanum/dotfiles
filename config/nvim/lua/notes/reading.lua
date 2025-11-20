-- Reading list picker for PDFs

local config = require('notes.config')
local yaml = require('notes.yaml')
local pick = require('mini.pick')

local M = {}

-- Create a reading list picker
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
                        p_value = yaml.get_property(line, p_name)
                    else
                        -- this is the 'todo' type
                        if not yaml.get_property(line, 'completion') and
                           not yaml.get_property(line, 'punted') then
                            p_value = yaml.get_property(line, 'created')
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
                    return yaml.date_to_ts(a.date) > yaml.date_to_ts(b.date)
                end)

                return filtered_lines
            end
        },
        {
            source = {
                cwd = config.notes_dir .. '/' .. local_opts.dir,
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

-- Show all reading list items
function M.all()
    pick.registry.reading_list({
        dir = 'PDFs',
        type = 'all',
    })
end

-- Show todo reading list items
function M.todo()
    pick.registry.reading_list({
        dir = 'PDFs',
        type = 'todo',
    })
end

-- Show completed reading list items
function M.completed()
    pick.registry.reading_list({
        dir = 'PDFs',
        type = 'completed',
    })
end

-- Show punted reading list items
function M.punted()
    pick.registry.reading_list({
        dir = 'PDFs',
        type = 'punted',
    })
end

return M
