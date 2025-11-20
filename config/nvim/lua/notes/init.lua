
--[[
NOTES SYSTEM

  config.lua    - Constants and configuration (paths, patterns)
  journal.lua   - Journal day and week entry management
  links.lua     - Broken wiki-link checker
  markdown.lua  - Markdown-specific utilities and filetype config
  misc.lua      - Random notes, quotes, recent files, PDF/Excalidraw
  reading.lua   - Reading list pickers for PDFs
  tags.lua      - Hashtag searching and file tag management
  tasks.lua     - Task searching, filtering, and toggling
  utils.lua     - Generic utility functions
  yaml.lua      - YAML frontmatter parsing and manipulation

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

require('notes.config')
require('notes.journal')
require('notes.links')
require('notes.markdown')
require('notes.misc')
require('notes.reading')
require('notes.tags')
require('notes.tasks')
require('notes.utils')
require('notes.yaml')

------------------------------------------------------------------------------
-- KEYMAPS ------------------------------------------------------------------
------------------------------------------------------------------------------

local kmap = require('keymaps').kmap

-- <leader>n<.> - Hashtag searching
local hashtag_maps = {
    { 'ng', 'NotesTagSearch', '[N]otes Ta[G]s' },
    { 'ns', 'NotesTagSelect', '[N]otes Tag [S]earch' },
}
for _, m in ipairs(hashtag_maps) do
    kmap('n', '<leader>' .. m[1], '<Cmd>' .. m[2] .. '<CR>', { desc = m[3] })
end

-- <leader>mt<.> - File tag management
local file_tag_maps = {
    { 'mta', 'NotesTagAdd',    '[M]arkdown [T]ag [A]dd to file' },
    { 'mtr', 'NotesTagRemove', '[M]arkdown [T]ag [R]emove from file' },
}
for _, m in ipairs(file_tag_maps) do
    kmap('n', '<leader>' .. m[1], '<Cmd>' .. m[2] .. '<CR>', { desc = m[3] })
end

-- <leader>nt<.> - Task searching
local task_search_maps = {
    { 'nta', 'NotesTasksAll',       '[N]otes [T]asks [A]ll' },
    { 'nto', 'NotesTasksOpen',      '[N]otes [T]asks [O]pen' },
    { 'ntc', 'NotesTasksCompleted', '[N]otes [T]asks [C]ompleted' },
    { 'ntp', 'NotesTasksPunted',    '[N]otes [T]asks [P]unted' },
    { 'ntr', 'NotesTasksRecent',    '[N]otes [T]asks [R]ecent (Past 6 Months)' },
}
for _, m in ipairs(task_search_maps) do
    kmap('n', '<leader>' .. m[1], '<Cmd>' .. m[2] .. '<CR>', { desc = m[3] })
end

-- <leader>n<.> - Task toggling
local task_toggle_maps = {
    { 'nc', 'NotesTaskToggleComplete', '[N]otes [C]omplete Task' },
    { 'np', 'NotesTaskTogglePunt',     '[N]otes [P]unt Task' },
}
for _, m in ipairs(task_toggle_maps) do
    kmap('n', '<leader>' .. m[1], '<Cmd>' .. m[2] .. '<CR>', { desc = m[3] })
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
    { 'nra', 'NotesReadingAll',       '[N]otes [R]ead [A]ll' },
    { 'nrt', 'NotesReadingTodo',      '[N]otes [R]ead [T]odo' },
    { 'nrc', 'NotesReadingCompleted', '[N]otes [R]ead [C]ompleted' },
    { 'nrp', 'NotesReadingPunted',    '[N]otes [R]ead [P]unted' },
}
for _, m in ipairs(reading_maps) do
    kmap('n', '<leader>' .. m[1], '<Cmd>' .. m[2] .. '<CR>', { desc = m[3] })
end

-- <leader>n<.> - Miscellaneous
local misc_maps = {
    { 'nP', 'NotesPdfOpen',        '[N]otes [P]DF Expert' },
    { 'nx', 'NotesExcalidrawEdit', '[N]otes E[X]calidraw' },
    { 'nB', 'NotesBrokenLinks',    '[N]otes [B]roken Links' },
    { 'nd', 'NotesRandom',         '[N]otes Ran[D]om' },
    { 'nq', 'NotesQuote',          '[N]otes Random [Q]uote' },
    { 'nR', 'NotesRecent',         '[N]otes [R]ecent' },
    { 'nh', 'NotesHelp',           '[N]otes [H]elp' },
}
for _, m in ipairs(misc_maps) do
    kmap('n', '<leader>' .. m[1], '<Cmd>' .. m[2] .. '<CR>', { desc = m[3] })
end

------------------------------------------------------------------------------
-- NOTES HELP COMMAND --------------------------------------------------------
------------------------------------------------------------------------------

local pick = require('mini.pick')

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

vim.api.nvim_create_user_command('NotesHelp', function()
    pick.start({
        source = {
            items = notes_help,
            name = 'Notes Help',
            choose = function() end
        },
    })
end, { desc = 'Show notes keymap reference' })

