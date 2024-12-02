return {
    'neovim/nvim-lspconfig',
    dependencies = {
        'williamboman/mason.nvim',
        'williamboman/mason-lspconfig.nvim',
        'WhoIsSethDaniel/mason-tool-installer.nvim',
        'hrsh7th/cmp-nvim-lsp',
    },

    config = function()

        require('mason').setup()

        -- Neovim doesn't support everything that is in the LSP specification.
        -- It can gain additional capabilities via plugins like nvim-cmp.
        -- Here the capabilities array is extended with nvim-cmp caps.
        local capabilities = vim.tbl_deep_extend(
            'force',
            vim.lsp.protocol.make_client_capabilities(),
            require('cmp_nvim_lsp').default_capabilities())

        -- See the following for config servers and config variables:
        -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
        local servers = {
            clangd = {},
            rust_analyzer = {},
            bashls = {},
            pyright = {},
            ts_ls = {},
            lua_ls = {
                settings = {
                    Lua = {
                        diagnostics = {
                            globals = { 'vim' } -- or install LazyDev
                        }
                    }
                },
            },
        }

        require('mason-tool-installer').setup({
            ensure_installed = vim.tbl_keys(servers or {}),
        })

        require('mason-lspconfig').setup({
            handlers = {
                function(server_name)
                    local server = servers[server_name] or {}
                    -- Override capability values explicitly set in the
                    -- server config above. Useful to disable certain
                    -- features of an LSP.
                    server.capabilities = vim.tbl_deep_extend(
                        'force',
                        capabilities,
                        server.capabilities or {})
                    require('lspconfig')[server_name].setup(server)
                end,
            },
        })

    end,
}
