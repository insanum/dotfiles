-- Flashcard tester with Leitner (+ Hard/Easy) spaced repetition.
--
-- A deck is any markdown file with `flashcards: true` in its YAML
-- frontmatter. Each `## ` (H2) header is a card: the header text is the
-- front, the body until the next `##` is the back. A line containing only
-- `%` splits the body so that lines ABOVE it are extra front context and
-- lines BELOW are the back.
--
-- Per-card scheduling state lives in a sidecar JSON next to the deck
-- (Deck.md -> Deck.fc.json), keyed by a short stable id injected into each
-- card header as an HTML comment: `## Front <!-- fc:a1b2c3d4 -->`.

local config = require('notes.config')
local pick   = require('mini.pick')
local utils  = require('notes.utils')
local yaml   = require('notes.yaml')

local M = {}

------------------------------------------------------------------------------
-- SCHEDULING (Leitner boxes) ------------------------------------------------
------------------------------------------------------------------------------

local MAX_BOX = 6

-- box -> interval in days until the card is due again
local INTERVALS = { [1] = 1, [2] = 3, [3] = 7, [4] = 16, [5] = 35, [6] = 90 }

------------------------------------------------------------------------------
-- DATE HELPERS (noon-anchored => DST safe) ----------------------------------
------------------------------------------------------------------------------

local function today_str()
    return os.date('%Y-%m-%d')
end

-- add `days` to an ISO date string, returning a new ISO date string
local function add_days(date_str, days)
    local y, m, d = date_str:match('(%d+)-(%d+)-(%d+)')
    if not y then
        return date_str
    end
    local t = os.time({ year = y, month = m, day = d, hour = 12 })
    return os.date('%Y-%m-%d', t + (days * 86400))
end

-- ISO date strings compare correctly with plain lexical <=
local function is_due(due)
    return (due == nil) or (due <= today_str())
end

------------------------------------------------------------------------------
-- UNIQUE CARD IDS -----------------------------------------------------------
------------------------------------------------------------------------------

local _id_counter = 0

-- short 8-char id derived from time + a counter + seed text
local function gen_id(seed)
    _id_counter = _id_counter + 1
    local raw = tostring(os.time()) .. tostring(os.clock()) ..
                tostring(_id_counter) .. tostring(seed or '')
    return vim.fn.sha256(raw):sub(1, 8)
end

------------------------------------------------------------------------------
-- SIDECAR STATE I/O ---------------------------------------------------------
------------------------------------------------------------------------------

local function sidecar_path(filepath)
    return (filepath:gsub('%.md$', '') .. '.fc.json')
end

local function load_state(filepath)
    local f = io.open(sidecar_path(filepath), 'r')
    if not f then
        return {}
    end
    local content = f:read('*a')
    f:close()
    if not content or content == '' then
        return {}
    end
    local ok, data = pcall(vim.json.decode, content)
    if ok and type(data) == 'table' then
        return data
    end
    return {}
end

local function save_state(filepath, state)
    local ok, encoded = pcall(vim.json.encode, state)
    if not ok then
        vim.notify('flashcards: failed to encode state', vim.log.levels.ERROR)
        return
    end
    vim.fn.writefile({ encoded }, sidecar_path(filepath))
end

------------------------------------------------------------------------------
-- PARSING -------------------------------------------------------------------
------------------------------------------------------------------------------

-- a line is a card header if it starts with exactly '## ' and is not in a
-- fenced code block
local function is_card_header(line, lnum, cb)
    return line:match('^##%s') ~= nil and
           not utils.utils_is_in_codeblock(lnum, cb)
end

-- trim leading/trailing blank lines from an array of strings
local function trim_blank(lines)
    local s, e = 1, #lines
    while s <= e and lines[s]:match('^%s*$') do s = s + 1 end
    while e >= s and lines[e]:match('^%s*$') do e = e - 1 end
    local out = {}
    for i = s, e do out[#out + 1] = lines[i] end
    return out
end

-- Parse a deck file into a list of cards.
-- Returns: cards (array of { uuid, front, back, header_lnum }), malformed
local function parse_deck(filepath)
    local f = io.open(filepath, 'r')
    if not f then
        return {}, 0
    end
    local lines = {}
    for l in f:lines() do lines[#lines + 1] = l end
    f:close()

    local cb = utils.utils_get_codeblock_ranges(filepath)
    local cards = {}
    local malformed = 0
    local cur = nil

    local function finalize()
        if not cur then return end

        -- locate the '%' separator line (if any) in the body
        local pct = nil
        for i, bl in ipairs(cur.body) do
            if bl.text:match('^%s*%%%s*$') and
               not utils.utils_is_in_codeblock(bl.lnum, cb) then
                pct = i
                break
            end
        end

        local front_extra, back = {}, {}
        if pct then
            for i = 1, pct - 1 do front_extra[#front_extra + 1] = cur.body[i].text end
            for i = pct + 1, #cur.body do back[#back + 1] = cur.body[i].text end
        else
            for i = 1, #cur.body do back[#back + 1] = cur.body[i].text end
        end

        front_extra = trim_blank(front_extra)
        back = trim_blank(back)

        local front = cur.title
        if #front_extra > 0 then
            front = front .. '\n' .. table.concat(front_extra, '\n')
        end
        local back_str = table.concat(back, '\n')

        -- a card with no back content is malformed; skip it
        if back_str:match('^%s*$') then
            malformed = malformed + 1
            cur = nil
            return
        end

        cards[#cards + 1] = {
            uuid = cur.uuid,
            front = front,
            back = back_str,
            header_lnum = cur.lnum,
        }
        cur = nil
    end

    for lnum, line in ipairs(lines) do
        if is_card_header(line, lnum, cb) then
            finalize()
            local rest = line:match('^##%s+(.*)$') or ''
            local uuid = rest:match('<!%-%- fc:(%w+) %-%->')
            local title = rest:gsub('%s*<!%-%- fc:%w+ %-%->%s*$', '')
            title = title:gsub('%s+$', '')
            cur = { title = title, uuid = uuid, lnum = lnum, body = {} }
        elseif cur then
            cur.body[#cur.body + 1] = { text = line, lnum = lnum }
        end
    end
    finalize()

    return cards, malformed
end

-- Inject a stable id into any card header that lacks one (writes the file
-- once if anything changed).
local function ensure_ids(filepath)
    local f = io.open(filepath, 'r')
    if not f then return end
    local lines = {}
    for l in f:lines() do lines[#lines + 1] = l end
    f:close()

    local cb = utils.utils_get_codeblock_ranges(filepath)
    local seen = {}
    local modified = false

    -- collect existing ids first to avoid collisions
    for lnum, line in ipairs(lines) do
        if is_card_header(line, lnum, cb) then
            local id = line:match('<!%-%- fc:(%w+) %-%->')
            if id then seen[id] = true end
        end
    end

    for lnum, line in ipairs(lines) do
        if is_card_header(line, lnum, cb) and
           not line:match('<!%-%- fc:%w+ %-%->') then
            local id
            repeat id = gen_id(line) until not seen[id]
            seen[id] = true
            lines[lnum] = line:gsub('%s+$', '') .. ' <!-- fc:' .. id .. ' -->'
            modified = true
        end
    end

    if modified then
        vim.fn.writefile(lines, filepath)
    end
end

-- Drop sidecar entries whose card no longer exists in the deck.
local function gc_state(filepath, cards, state)
    local valid = {}
    for _, c in ipairs(cards) do
        if c.uuid then valid[c.uuid] = true end
    end
    local changed = false
    for id in pairs(state) do
        if not valid[id] then
            state[id] = nil
            changed = true
        end
    end
    if changed then
        save_state(filepath, state)
    end
end

------------------------------------------------------------------------------
-- DECK DISCOVERY & STATUS ---------------------------------------------------
------------------------------------------------------------------------------

local function is_deck_file(filepath)
    if not filepath or not filepath:match('%.md$') then
        return false
    end
    return yaml.yaml_get_property(filepath, 'flashcards') == 'true'
end

local function find_deck_files()
    local out = vim.fn.systemlist({
        'rg', '-l', '--glob', '*.md', '-e', '^flashcards:[ \t]*true',
        '--', config.notes_dir,
    })
    local files = {}
    if vim.v.shell_error ~= 0 then
        return files -- rg returns non-zero when there are no matches
    end
    for _, fp in ipairs(out) do
        if is_deck_file(fp) then
            files[#files + 1] = fp
        end
    end
    table.sort(files)
    return files
end

-- Count cards by state for the deck picker (read-only; never writes).
local function deck_status(filepath)
    local cards, malformed = parse_deck(filepath)
    local state = load_state(filepath)
    local s = { total = #cards, new = 0, due = 0, learn = 0, susp = 0,
                malformed = malformed }
    for _, c in ipairs(cards) do
        local e = c.uuid and state[c.uuid] or nil
        if not e then
            s.new = s.new + 1
        elseif e.suspended then
            s.susp = s.susp + 1
        elseif is_due(e.due) then
            s.due = s.due + 1
        else
            s.learn = s.learn + 1
        end
    end
    return s
end

-- Build the review list for one deck. mode = 'due' or 'cram'.
-- Returns: cards (each tagged with .file), states = { [filepath] = state }
local function gather_deck(filepath, mode)
    ensure_ids(filepath)
    local cards = parse_deck(filepath)
    local state = load_state(filepath)
    gc_state(filepath, cards, state)

    local list = {}
    for _, c in ipairs(cards) do
        c.file = filepath
        local e = c.uuid and state[c.uuid] or nil
        if mode == 'cram' then
            if not (e and e.suspended) then
                list[#list + 1] = c
            end
        else
            if e and e.suspended then
                -- skip suspended
            elseif (not e) or is_due(e.due) then
                list[#list + 1] = c
            end
        end
    end

    return list, { [filepath] = state }
end

------------------------------------------------------------------------------
-- GRADING -------------------------------------------------------------------
------------------------------------------------------------------------------

-- Apply a grade to a card's prior entry and return the new entry.
-- grade is one of: 'again' | 'hard' | 'good' | 'easy'
local function apply_grade(prev, grade)
    local box     = (prev and prev.box) or 0
    local reps    = ((prev and prev.reps) or 0) + 1
    local lapses  = (prev and prev.lapses) or 0
    local history = (prev and prev.history) or {}
    local today   = today_str()

    local newbox, due, st
    if grade == 'again' then
        newbox = 1
        lapses = lapses + 1
        due = today
        st = 'relearning'
    elseif grade == 'hard' then
        newbox = (box < 1) and 1 or box
        due = add_days(today, INTERVALS[newbox])
        st = 'review'
    elseif grade == 'good' then
        newbox = (box < 1) and 1 or math.min(box + 1, MAX_BOX)
        due = add_days(today, INTERVALS[newbox])
        st = 'review'
    else -- 'easy'
        newbox = (box < 1) and 2 or math.min(box + 2, MAX_BOX)
        due = add_days(today, INTERVALS[newbox])
        st = 'review'
    end

    history[#history + 1] = { date = today, grade = grade }

    return {
        box = newbox, due = due, last = today,
        reps = reps, lapses = lapses, state = st, history = history,
    }
end

------------------------------------------------------------------------------
-- REVIEW SESSION (floating window UI) ---------------------------------------
------------------------------------------------------------------------------

local KEY_GRADE = {
    j = 'again', n = 'again',
    h = 'hard',
    k = 'good',  y = 'good',
    l = 'easy',
}

-- in-place Fisher-Yates shuffle
local function shuffle(list)
    for i = #list, 2, -1 do
        local j = math.random(i)
        list[i], list[j] = list[j], list[i]
    end
end

local function start_session(cards, states, title, cram)
    if #cards == 0 then
        vim.notify('No cards to review', vim.log.levels.INFO)
        return
    end

    -- quiz cards in random order each run
    math.randomseed(vim.uv.hrtime())
    shuffle(cards)

    local idx = 1
    local flipped = false
    local graded = 0
    local undo_stack = {}

    local width = math.min(80, vim.o.columns - 4)
    local height = math.min(22, vim.o.lines - 4)

    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_open_win(buf, true, {
        relative = 'editor',
        width = width,
        height = height,
        col = math.floor((vim.o.columns - width) / 2),
        row = math.floor((vim.o.lines - height) / 2),
        style = 'minimal',
        border = 'rounded',
        title = ' Flashcards ',
    })
    vim.api.nvim_set_option_value('wrap', true, { win = win })
    vim.api.nvim_set_option_value('linebreak', true, { win = win })

    local function close()
        if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
        end
    end

    local function append(lines, text)
        for _, l in ipairs(vim.split(text, '\n', { plain = true })) do
            lines[#lines + 1] = l
        end
    end

    local function render()
        local card = cards[idx]
        local hdr = string.format('%s   [%d/%d]   graded %d%s',
                                  title, idx, #cards, graded,
                                  cram and '   (cram)' or '')
        local lines = { hdr, string.rep('─', width - 2), '' }
        append(lines, card.front)
        if flipped then
            lines[#lines + 1] = ''
            lines[#lines + 1] = string.rep('─', width - 2)
            lines[#lines + 1] = ''
            append(lines, card.back)
        end
        lines[#lines + 1] = ''
        local hint = flipped
            and '[j/n] again  [h] hard  [k/y] good  [l] easy  [p] prev  [u] undo  [e] edit  [s] suspend  [q] quit'
            or  '[<space>] flip  [p] prev  [e] edit  [q] quit'

        vim.api.nvim_set_option_value('modifiable', true, { buf = buf })
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
        -- footer hint pinned at the bottom region
        vim.api.nvim_buf_set_lines(buf, -1, -1, false, { '', hint })
        vim.api.nvim_set_option_value('modifiable', false, { buf = buf })
    end

    local function finish()
        close()
        vim.notify(string.format('Review done: %d graded', graded),
                   vim.log.levels.INFO)
    end

    local function advance()
        idx = idx + 1
        flipped = false
        if idx > #cards then
            finish()
        else
            render()
        end
    end

    local function flip()
        if not flipped then
            flipped = true
            render()
        end
    end

    local function prev()
        if idx > 1 then
            idx = idx - 1
            flipped = false
            render()
        end
    end

    local function grade(g)
        if not flipped then return end
        local card = cards[idx]
        if not cram and card.uuid then
            local st = states[card.file]
            table.insert(undo_stack,
                         { file = card.file, uuid = card.uuid,
                           prev = st[card.uuid] })
            st[card.uuid] = apply_grade(st[card.uuid], g)
            save_state(card.file, st)
        end
        graded = graded + 1
        advance()
    end

    local function suspend()
        local card = cards[idx]
        if not cram and card.uuid then
            local st = states[card.file]
            table.insert(undo_stack,
                         { file = card.file, uuid = card.uuid,
                           prev = st[card.uuid] })
            local e = st[card.uuid] or { box = 0, reps = 0, lapses = 0,
                                         history = {} }
            e.suspended = true
            e.state = 'suspended'
            st[card.uuid] = e
            save_state(card.file, st)
        end
        advance()
    end

    local function undo()
        local last = table.remove(undo_stack)
        if not last then return end
        local st = states[last.file]
        st[last.uuid] = last.prev
        save_state(last.file, st)
        if graded > 0 then graded = graded - 1 end
        idx = math.max(1, idx - 1)
        flipped = true
        render()
    end

    local function edit()
        local card = cards[idx]
        local file, lnum = card.file, card.header_lnum
        close()
        vim.cmd('edit ' .. vim.fn.fnameescape(file))
        if lnum then
            vim.api.nvim_win_set_cursor(0, { lnum, 0 })
        end
    end

    local function map(key, fn)
        vim.keymap.set('n', key, fn, { buffer = buf, nowait = true, silent = true })
    end

    map('<Space>', flip)
    for key, g in pairs(KEY_GRADE) do
        map(key, function() grade(g) end)
    end
    map('p', prev)
    map('u', undo)
    map('e', edit)
    map('s', suspend)
    map('q', close)
    map('<Esc>', close)

    render()
end

------------------------------------------------------------------------------
-- COMMANDS ------------------------------------------------------------------
------------------------------------------------------------------------------

local function review_current()
    local fp = vim.api.nvim_buf_get_name(0)
    if not is_deck_file(fp) then
        vim.notify('Not a flashcard deck (needs "flashcards: true")',
                   vim.log.levels.WARN)
        return
    end
    vim.cmd('silent! update')
    local cards, states = gather_deck(fp, 'due')
    start_session(cards, states, vim.fn.fnamemodify(fp, ':t:r'), false)
end

local function cram_current()
    local fp = vim.api.nvim_buf_get_name(0)
    if not is_deck_file(fp) then
        vim.notify('Not a flashcard deck (needs "flashcards: true")',
                   vim.log.levels.WARN)
        return
    end
    vim.cmd('silent! update')
    local cards, states = gather_deck(fp, 'cram')
    start_session(cards, states, vim.fn.fnamemodify(fp, ':t:r'), true)
end

local function reset_current()
    local fp = vim.api.nvim_buf_get_name(0)
    if not is_deck_file(fp) then
        vim.notify('Not a flashcard deck (needs "flashcards: true")',
                   vim.log.levels.WARN)
        return
    end
    local name = vim.fn.fnamemodify(fp, ':t:r')
    utils.utils_confirm_and_run('Reset ALL state for "' .. name .. '"',
        function()
            local p = sidecar_path(fp)
            if vim.uv.fs_stat(p) then
                vim.uv.fs_unlink(p)
            end
            vim.notify('Reset deck: ' .. name, vim.log.levels.INFO)
        end)
end

local function decks_picker()
    local files = find_deck_files()
    if #files == 0 then
        vim.notify('No flashcard decks found (need "flashcards: true")',
                   vim.log.levels.WARN)
        return
    end

    local items = {}
    for _, fp in ipairs(files) do
        items[#items + 1] = {
            file = fp,
            name = vim.fn.fnamemodify(fp, ':t:r'),
            status = deck_status(fp),
        }
    end

    -- decks with the most actionable cards (due + new) first
    table.sort(items, function(a, b)
        return (a.status.due + a.status.new) > (b.status.due + b.status.new)
    end)

    pick.start({
        source = {
            items = items,
            name = 'Flashcard Decks',
            show = function(buf_id, its, query)
                local disp = {}
                for _, it in ipairs(its) do
                    local s = it.status
                    disp[#disp + 1] = string.format(
                        '%-32s %4d cards   new %-3d due %-3d learn %-3d susp %-3d%s',
                        it.name, s.total, s.new, s.due, s.learn, s.susp,
                        s.malformed > 0
                            and ('   ⚠ ' .. s.malformed .. ' malformed') or '')
                end
                return pick.default_show(buf_id, disp, query,
                                         { show_icons = false })
            end,
            choose = function(it)
                if not it then return end
                vim.schedule(function()
                    local cards, states = gather_deck(it.file, 'due')
                    start_session(cards, states, it.name, false)
                end)
            end,
        },
    })
end

local function tag_matches(ftags, tag)
    if not ftags then return false end
    if type(ftags) == 'string' then return ftags == tag end
    for _, t in ipairs(ftags) do
        if t == tag then return true end
    end
    return false
end

local function review_by_tag()
    vim.ui.input({ prompt = 'Flashcard tag: ' }, function(input)
        if not input or input == '' then return end
        local tag = input:gsub('^#', ''):gsub('%s+', '')

        local cards, states = {}, {}
        for _, fp in ipairs(find_deck_files()) do
            if tag_matches(yaml.yaml_get_property(fp, 'tags'), tag) then
                local c, s = gather_deck(fp, 'due')
                for _, cc in ipairs(c) do cards[#cards + 1] = cc end
                for k, v in pairs(s) do states[k] = v end
            end
        end

        if #cards == 0 then
            vim.notify('No due cards for tag #' .. tag, vim.log.levels.INFO)
            return
        end
        start_session(cards, states, '#' .. tag, false)
    end)
end

------------------------------------------------------------------------------
-- REGISTER COMMANDS ---------------------------------------------------------
------------------------------------------------------------------------------

vim.api.nvim_create_user_command('NotesFlashDecks', decks_picker,
    { desc = 'Flashcards: pick a deck (shows status) and review it' })

vim.api.nvim_create_user_command('NotesFlashReview', review_current,
    { desc = 'Flashcards: review due cards in the current deck' })

vim.api.nvim_create_user_command('NotesFlashCram', cram_current,
    { desc = 'Flashcards: review ALL cards in the current deck (no schedule)' })

vim.api.nvim_create_user_command('NotesFlashTag', review_by_tag,
    { desc = 'Flashcards: review due cards across decks by tag' })

vim.api.nvim_create_user_command('NotesFlashReset', reset_current,
    { desc = 'Flashcards: reset ALL scheduling state for the current deck' })

return M
