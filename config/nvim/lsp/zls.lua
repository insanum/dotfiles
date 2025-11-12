return {
    cmd = {
        vim.fn.stdpath('data') .. '/mason/bin/zls'
    },
    root_markers = {
        'zls.json',
        'build.zig',
        '.git',
    },
    filetypes = {
        'zig',
        'zar',
    },
}
