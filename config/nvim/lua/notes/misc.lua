-- Miscellaneous notes utilities: random notes, quotes, recent files, help

local config = require('notes.config')
local yaml = require('notes.yaml')
local utils = require('notes.utils')
local pick = require('mini.pick')

local M = {}

-- Pick a random note from the collection
function M.random_note()
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
                cwd = config.notes_dir,
                name = 'Random Note',
            },
        }
    )
end

-- Get a random stoicism quote
local function get_random_stoicism_quote()
    local stoicism_file = config.notes_dir .. '/snips/stoicism_quotes.json'

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

-- Get a random quote from Quotes.md
local function get_random_quote_md()
    local quotes_file = config.notes_dir .. '/Quotes.md'
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

-- Display random quotes in a floating window
function M.random_quote()
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
    vim.api.nvim_set_option_value('modifiable', false, { buf = buf })
    vim.api.nvim_set_option_value('bufhidden', 'wipe', { buf = buf })

    -- calculate window size to fit all content
    local width = 70
    local visual_height = 0
    for _, line in ipairs(lines) do
        local line_length = vim.fn.strdisplaywidth(line)
        visual_height =
            visual_height + math.max(1, math.ceil(line_length / width))
    end

    local max_height = math.floor(vim.o.lines * 0.8)
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

    vim.api.nvim_set_option_value('wrap', true, { win = win })
    vim.api.nvim_set_option_value('linebreak', true, { win = win })

    -- close with 'q' or ESC
    local close_win = function()
        vim.api.nvim_win_close(win, true)
    end
    vim.keymap.set('n', 'q', close_win, { buffer = buf, noremap = true })
    vim.keymap.set('n', '<Esc>', close_win, { buffer = buf, noremap = true })
end

-- Recent files picker
pick.registry.recent_files = function(local_opts)
    return pick.builtin.cli(
        {
            command = {
                'fd', '-e', 'md',
            },
            postprocess = function(items)
                local files = {}

                for _, filepath in ipairs(items) do
                    local date = nil

                    for _, exclude in ipairs(local_opts.exclude or {}) do
                        if string.match(filepath, exclude) then
                            goto continue
                        end
                    end

                    -- try to extract the date from the yaml
                    local yaml_data = yaml.get(filepath)
                    if yaml_data then
                        if yaml_data.updated then
                            date = yaml.date_to_ts(yaml_data.updated)
                        elseif yaml_data.created then
                            date = yaml.date_to_ts(yaml_data.created)
                        end
                    end

                    -- fallback to file modification time
                    if not date then
                        date = utils.get_file_mtime(filepath)
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
                cwd = config.notes_dir,
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

-- Show recent notes
function M.recent()
    pick.registry.recent_files({
        exclude = { 'Journal', 'templates', },
    })
end

-- Notes help keymap reference
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
    '<leader>nB                         Find broken links',
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

-- Show notes help
function M.help()
    pick.registry.notes_help()
end

return M
