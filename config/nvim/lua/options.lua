
vim.opt.title = false

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.mouse = ''
vim.opt.clipboard = ''

vim.opt.breakindent = true

vim.opt.undofile = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.signcolumn = 'yes'

vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

vim.opt.list = false
vim.opt.listchars = { tab = '«·»', trail = '·', nbsp = '␣' }

vim.opt.inccommand = 'split'

vim.opt.cursorline = true
vim.opt.colorcolumn = '80'

vim.opt.scrolloff = 10

-- vim.opt.showtabline = 2

vim.opt.splitright = false
vim.opt.splitbelow = false

-- vim.opt.winheight = 10
-- vim.opt.winminheight = 10
-- vim.opt.winwidth = 10
-- vim.opt.winminwidth = 10

vim.opt.showmode = false

vim.diagnostic.config({
    virtual_text = {
        virt_text_pos = 'eol',
        prefix = ' ',
        spacing = 0,
    },
    float = {
        focusable = false,
        style = 'minimal',
        border = 'rounded',
        source = 'always',
        header = '',
        prefix = '',
    },
})

vim.g.zig_fmt_autosave = 0

