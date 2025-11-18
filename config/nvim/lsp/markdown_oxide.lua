return {
    capabilities = {
        workspace = {
            didChangeWatchedFiles = {
                dynamicRegistration = true,
            },
        },
    },
    cmd = {
        vim.fn.stdpath('data') .. '/mason/bin/markdown-oxide'
    },
    root_markers = {
        '.git',
    },
    filetypes = {
        'md',
    },
}
