return {
    cmd = { vim.fn.stdpath('data') .. '/mason/bin/clangd', '--background-index', '--clang-tidy' },
    root_markers = {
        '.clangd',
        '.clang-tidy',
        '.clang-format',
        'compile_commands.json',
        'compile_flags.txt',
        'configure.ac',
        '.git',
    },
    filetypes = {
        'c',
        'cpp',
        'objc',
        'objcpp',
        'cuda',
        'proto',
    },
}
