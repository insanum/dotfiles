
return {
    cmd = { vim.fn.stdpath('data') .. '/mason/bin/typescript-language-server', '--stdio' },
    root_markers = {
        'tsconfig.json',
        'jsconfig.json',
        'package.json',
        '.git',
    },
    filetypes = {
        'javascript',
        'javascriptreact',
        'javascript.jsx',
        'typescript',
        'typescriptreact',
        'typescript.tsx',
    },
}
