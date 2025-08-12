
-- split window borders
vim.cmd.hi 'WinSeparator guifg=#5e81ac'

-- all comments rendered in italics
vim.cmd.hi 'Comment gui=none cterm=italic gui=italic'

-- virtual text (for search) needs to stand out more
vim.cmd.hi 'link NoiceVirtualText IncSearch'

-- tabline text needs to stand out more
vim.cmd.hi 'TabLine guifg=#e0af68'

-- render-markdown tweaks
vim.cmd.hi 'RenderMarkdownCode guibg=#2e3440'
vim.cmd.hi 'RenderMarkdownCodeInline guibg=#2e3440'

