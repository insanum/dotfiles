return {
    cmd = {
        vim.fn.stdpath('data') .. '/mason/bin/pyright-langserver',
        '--stdio'
    },
    root_markers = {
        'pyproject.toml',
        'setup.py',
        'setup.cfg',
        'requirements.txt',
        'Pipfile',
        'pyrightconfig.json',
        '.git',
    },
    filetypes = {
        'python',
    },
}
