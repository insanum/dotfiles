-- Configuration and constants for the notes system

local M = {}

-- Directory paths
M.notes_dir = '/Volumes/work/notes'
M.journal_dir = M.notes_dir .. '/Journal'
M.pdf_dir = M.notes_dir .. '/PDFs/'
M.assets_dir = M.notes_dir .. '/assets/'
M.excli_blank = M.assets_dir .. 'blank.excalidraw'

-- Regex patterns
M.PATTERNS = {
    DATE = '%d%d%d%d%-%d%d%-%d%d',
    DATE_ISO = '^%d%d%d%d%-%d%d%-%d%d$',
    CHECKBOX_DONE = '^%s*-%s*%[x%]',
    CHECKBOX_PUNTED = '^%s*-%s*%[%-]',
    CHECKBOX_OPEN = '^%s*-%s*%[%s%]',
    COMPLETION_TAG = '%%[completion:: (%s)%%]',
    PUNTED_TAG = '%%[punted:: (%s)%%]',
}

-- Ripgrep defaults
M.RG_DEFAULTS = { '--no-heading', '--line-number', '--color=never' }
M.RG_MD_GLOB = { '--glob', '*.md' }

return M
