return {
    cmd = { vim.fn.stdpath('data') .. '/mason/bin/bash-language-server', 'start' },
    root_markers = {
        '.git',
    },
    filetypes = {
        'bash',
        'sh',
    },
}
