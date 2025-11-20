-- Miscellaneous notes utilities: random notes, quotes, recent files, PDF/Excalidraw

local config = require('notes.config')
local pick   = require('mini.pick')
local utils  = require('notes.utils')
local yaml   = require('notes.yaml')

-- Open PDF in external app
local function run_pdf_expert(file_path)
    vim.notify('Opening "' .. file_path .. '"', vim.log.levels.INFO)
    vim.system({ 'open', file_path }, function()
        vim.notify('Done editing "' .. file_path .. '"', vim.log.levels.INFO)
    end)
end

-- Open PDF from file link under cursor
local function open_pdf()
    local file = vim.fn.expand('<cfile>:t')
    if not string.match(file, '%.pdf$') then
        vim.notify('PDF only', vim.log.levels.ERROR)
        return
    end

    local file_path = config.pdf_dir .. file

    if vim.fn.filereadable(file_path) == 0 then
        vim.notify('PDF doesn\'t exist', vim.log.levels.ERROR)
        return
    end

    utils.utils_confirm_and_run('Open "' .. file .. '"', function()
        run_pdf_expert(file_path)
    end)
end

-- Run Excalidraw on a file
local function run_excalidraw(efile_path)
    if vim.fn.filereadable(efile_path) == 0 then
        if vim.fn.filereadable(config.excli_blank) == 0 then
            vim.notify('Blank Excalidraw file not found',
                       vim.log.levels.ERROR)
            return
        end

        vim.system({ 'cp', '-f', config.excli_blank, efile_path }):wait()
    end

    vim.notify('Opening "' .. efile_path .. '"', vim.log.levels.INFO)
    vim.system({ 'excli', efile_path }, function()
        vim.notify('Done editing "' .. efile_path .. '"',
                   vim.log.levels.INFO)
    end)
end

-- Edit Excalidraw image under cursor
local function open_excalidraw()
    local file = vim.fn.expand('<cfile>')
    if not string.match(file, '%.excalidraw.png$') then
        vim.notify('Excalidraw/PNG only', vim.log.levels.ERROR)
        return
    end

    local efile = string.gsub(file, '^(.+).png$', '%1')

    local file_path = config.assets_dir .. file
    local efile_path = config.assets_dir .. efile

    local prompt = 'Edit "' .. efile .. '"'
    if vim.fn.filereadable(file_path) == 0 then
        prompt = 'Create and ' .. prompt
    end

    utils.utils_confirm_and_run(prompt, function()
        run_excalidraw(efile_path)
    end)
end

-- Pick a random note from the collection
local function random_note()
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
local function random_quote()
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
local function recent_files(local_opts)
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
                    local yaml_data = yaml.yaml_get(filepath)
                    if yaml_data then
                        if yaml_data.updated then
                            date = utils.utils_date_to_ts(yaml_data.updated)
                        elseif yaml_data.created then
                            date = utils.utils_date_to_ts(yaml_data.created)
                        end
                    end

                    -- fallback to file modification time
                    if not date then
                        date = utils.utils_get_file_mtime(filepath)
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

-- register commands

vim.api.nvim_create_user_command('NotesRandom', random_note,
    { desc = 'Open a random note' })

vim.api.nvim_create_user_command('NotesQuote', random_quote,
    { desc = 'Show random quote' })

vim.api.nvim_create_user_command('NotesRecent', function()
    recent_files({ exclude = { 'Journal', 'templates', } })
end, { desc = 'Show recent notes' })

vim.api.nvim_create_user_command('NotesPdfOpen', open_pdf,
    { desc = 'Open PDF under cursor in external app' })

vim.api.nvim_create_user_command('NotesExcalidrawEdit', open_excalidraw,
    { desc = 'Edit Excalidraw image under cursor' })

