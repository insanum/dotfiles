-- Reading list picker for PDFs

local config = require('notes.config')
local pick   = require('mini.pick')
local utils  = require('notes.utils')
local yaml   = require('notes.yaml')

-- Create a reading list picker
local function reading_list(reading_type)
    return pick.builtin.cli(
        {
            command = {
                'fd', '-e', 'md',
            },
            postprocess = function(lines)
                local filtered_lines = {}

                local p_name = nil
                if reading_type == 'all' then
                    p_name = 'created'
                elseif reading_type == 'completed' then
                    p_name = 'completion'
                elseif reading_type == 'punted' then
                    p_name = 'punted'
                end

                for _, line in ipairs(lines) do
                    local p_value = nil
                    if p_name then
                        p_value = yaml.yaml_get_property(line, p_name)
                    else
                        -- this is the 'todo' type
                        if not yaml.yaml_get_property(line, 'completion') and
                           not yaml.yaml_get_property(line, 'punted') then
                            p_value = yaml.yaml_get_property(line, 'created')
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
                    return utils.utils_date_to_ts(a.date) >
                           utils.utils_date_to_ts(b.date)
                end)

                return filtered_lines
            end
        },
        {
            source = {
                cwd = config.pdf_dir,
                name = 'Read: ' .. reading_type,
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

-- register commands

vim.api.nvim_create_user_command('NotesReadingAll', function()
    reading_list('all')
end, { desc = 'Show all reading list items' })

vim.api.nvim_create_user_command('NotesReadingTodo', function()
    reading_list('todo')
end, { desc = 'Show todo reading list items' })

vim.api.nvim_create_user_command('NotesReadingCompleted', function()
    reading_list('completed')
end, { desc = 'Show completed reading list items' })

vim.api.nvim_create_user_command('NotesReadingPunted', function()
    reading_list('punted')
end, { desc = 'Show punted reading list items' })

