
--[[
NOTES SYSTEM

  config.lua    - Constants and configuration (paths, patterns)
  yaml.lua      - YAML frontmatter parsing and manipulation
  tags.lua      - Hashtag searching and file tag management
  tasks.lua     - Task searching, filtering, and toggling
  journal.lua   - Journal day and week entry management
  reading.lua   - Reading list pickers for PDFs
  links.lua     - Broken wiki-link checker
  pdf.lua       - PDF and Excalidraw utilities
  markdown.lua  - Markdown-specific utilities and filetype config
  misc.lua      - Random notes, quotes, recent files, help
  utils.lua     - Generic utility functions

KEY FEATURES:
  - YAML frontmatter auto-update on save
  - Hashtag search with count display, codeblock-aware
  - Task management (open/completed/punted) with date tracking
  - Daily and weekly journal entries with templates
  - PDF reading list tracking with completion states
  - Broken link detection for [[wiki-links]\]
  - Random note selection
  - Random quote generator
  - Recent files sorted by YAML timestamps

USAGE:
  All keymaps and commands are registered below.
  See <leader>nh for a complete keymap reference!
--]]

local yaml     = require('notes.yaml')
local tags     = require('notes.tags')
local tasks    = require('notes.tasks')
local journal  = require('notes.journal')
local reading  = require('notes.reading')
local links    = require('notes.links')
local pdf      = require('notes.pdf')
local markdown = require('notes.markdown')
local misc     = require('notes.misc')
local kmap     = require('keymaps').kmap

-- Setup markdown filetype configuration
markdown.setup_filetype()

-- Setup markdown commands
markdown.setup_commands()

-- Setup YAML frontmatter auto-update
yaml.setup_autocmd()

------------------------------------------------------------------------------
-- KEYMAPS ------------------------------------------------------------------
------------------------------------------------------------------------------

-- <leader>n<.> - Hashtag searching
local hashtag_maps = {
    { 'ng', tags.search,            '[N]otes Ta[G]s' },
    { 'ns', tags.select_and_search, '[N]otes Tag [S]earch' },
}
for _, m in ipairs(hashtag_maps) do
    kmap('n', '<leader>' .. m[1], m[2], { desc = m[3] })
end

-- <leader>mt<.> - File tag management
local file_tag_maps = {
    { 'mta', tags.add_to_file,      '[M]arkdown [T]ag [A]dd to file' },
    { 'mtr', tags.remove_from_file, '[M]arkdown [T]ag [R]emove from file' },
}
for _, m in ipairs(file_tag_maps) do
    kmap('n', '<leader>' .. m[1], m[2], { desc = m[3] })
end

-- <leader>nt<.> - Task searching
local task_search_maps = {
    { 'nta', tasks.search_all,       '[N]otes [T]asks [A]ll' },
    { 'nto', tasks.search_open,      '[N]otes [T]asks [O]pen' },
    { 'ntc', tasks.search_completed, '[N]otes [T]asks [C]ompleted' },
    { 'ntp', tasks.search_punted,    '[N]otes [T]asks [P]unted' },
    { 'ntr', tasks.search_recent,    '[N]otes [T]asks [R]ecent (Past 6 Months)' },
}
for _, m in ipairs(task_search_maps) do
    kmap('n', '<leader>' .. m[1], m[2], { desc = m[3] })
end

-- <leader>n<.> - Task toggling
local task_toggle_maps = {
    { 'nc', tasks.toggle_completion, '[N]otes [C]omplete Task' },
    { 'np', tasks.toggle_punted,     '[N]otes [P]unt Task' },
}
for _, m in ipairs(task_toggle_maps) do
    kmap('n', '<leader>' .. m[1], m[2], { desc = m[3] })
end

-- <leader>jd<.> - Journal day
local journal_day_maps = {
    { 'jdd', 'Journal',        '[J]ournal [D]ay To[D]ay' },
    { 'jdp', 'Journal -1',     '[J]ournal [D]ay [P]rev' },
    { 'jdn', 'Journal +1',     '[J]ournal [D]ay [N]ext' },
    { 'jdm', 'JournalMissing', '[J]ournal [D]ay [M]issing' },
}
for _, m in ipairs(journal_day_maps) do
    kmap('n', '<leader>' .. m[1], '<Cmd>' .. m[2] .. '<CR>',
         { desc = m[3] })
end

-- <leader>jw<.> - Journal week
local journal_week_maps = {
    { 'jww', 'JournalWeek',        '[J]ournal [W]eek [W]eek' },
    { 'jwp', 'JournalWeek -1',     '[J]ournal [W]eek [P]rev' },
    { 'jwn', 'JournalWeek +1',     '[J]ournal [W]eek [N]ext' },
    { 'jwm', 'JournalWeekMissing', '[J]ournal [W]eek [M]issing' },
}
for _, m in ipairs(journal_week_maps) do
    kmap('n', '<leader>' .. m[1], '<Cmd>' .. m[2] .. '<CR>',
         { desc = m[3] })
end

-- <leader>nr<.> - Reading list
local reading_maps = {
    { 'nra', reading.all,       '[N]otes [R]ead [A]ll' },
    { 'nrt', reading.todo,      '[N]otes [R]ead [T]odo' },
    { 'nrc', reading.completed, '[N]otes [R]ead [C]ompleted' },
    { 'nrp', reading.punted,    '[N]otes [R]ead [P]unted' },
}
for _, m in ipairs(reading_maps) do
    kmap('n', '<leader>' .. m[1], m[2], { desc = m[3] })
end

-- <leader>n<.> - Miscellaneous
local misc_maps = {
    { 'nP', pdf.open,            '[N]otes [P]DF Expert' },
    { 'nx', pdf.edit_excalidraw, '[N]otes E[X]calidraw' },
    { 'nB', links.find,          '[N]otes [B]roken Links' },
    { 'nd', misc.random_note,    '[N]otes Ran[D]om' },
    { 'nq', misc.random_quote,   '[N]otes Random [Q]uote' },
    { 'nR', misc.recent,         '[N]otes [R]ecent' },
    { 'nh', misc.help,           '[N]otes [H]elp' },
}
for _, m in ipairs(misc_maps) do
    kmap('n', '<leader>' .. m[1], m[2], { desc = m[3] })
end

------------------------------------------------------------------------------
-- COMMANDS -----------------------------------------------------------------
------------------------------------------------------------------------------

-- Journal commands
vim.api.nvim_create_user_command('Journal', journal.open_day,
    { desc = 'Open journal entry (use +N/-N for offset)', nargs = '?' })

vim.api.nvim_create_user_command('JournalWeek', journal.open_week,
    { desc = 'Open journal week entry (use +N/-N for offset)', nargs = '?' })

vim.api.nvim_create_user_command('JournalMissing', journal.missing_days,
    { desc = 'List missing journal entries', nargs = '?' })

vim.api.nvim_create_user_command('JournalWeekMissing', journal.missing_weeks,
    { desc = 'List missing journal week entries', nargs = '?' })

