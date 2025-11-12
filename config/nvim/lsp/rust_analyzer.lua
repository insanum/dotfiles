return {
    cmd = {
        vim.fn.stdpath('data') .. '/mason/bin/rust-analyzer'
    },
    root_markers = {
        'Cargo.toml',
        '.git',
    },
    filetypes = {
        'rust',
    },
}
