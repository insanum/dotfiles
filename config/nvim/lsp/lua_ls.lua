return {
    cmd = {
        vim.fn.stdpath('data') .. '/mason/bin/lua-language-server'
    },
    root_markers = {
        '.luarc.json',
        '.luarc.jsonc',
        '.luacheckrc',
        '.stylua.toml',
        'stylua.toml',
        'selene.toml',
        'selene.yml',
        '.git',
    },
    filetypes = {
        'lua',
    },
    settings = {
        Lua = {
            workspace = {
                library = vim.api.nvim_get_runtime_file('', true),
            },
            -- diagnostics = {
            --   -- disable strict parameter count checks
            --   disable = { 'parameter-count' },
            -- },
        },
    },
}
