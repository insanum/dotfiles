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

        vim.api.nvim_create_autocmd('LspAttach', {
            group = vim.api.nvim_create_augroup('insanum-attach', { clear = true }),
            callback = function(event)
                local map = function(keys, func, desc, mode)
                    mode = mode or 'n'
                    vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
                end

                local tbin = require('telescope.builtin')

                map('gd', tbin.lsp_definitions, '[G]oto [D]efinition')
                map('gr', tbin.lsp_references, '[G]oto [R]eferences')
                map('gI', tbin.lsp_implementations, '[G]oto [I]mplementation')
                map('<leader>D', tbin.lsp_type_definitions, 'Type [D]efinition')
                map('<leader>ds', tbin.lsp_document_symbols, '[D]ocument [S]ymbols')
                map('<leader>ws', tbin.lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
                map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
                map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })
                map('K', vim.lsp.buf.hover, 'Hover Documentation')
                map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

                -- The following is used to highlight references of the word
                -- under the cursor when it rests there for a little while.
                local client = vim.lsp.get_client_by_id(event.data.client_id)
                if client and
                   client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
                    local highlight_augroup = vim.api.nvim_create_augroup('insanum-lsp-highlight', { clear = false })

                    vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                        buffer = event.buf,
                        group = highlight_augroup,
                        callback = vim.lsp.buf.document_highlight,
                    })

                    vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                        buffer = event.buf,
                        group = highlight_augroup,
                        callback = vim.lsp.buf.clear_references,
                    })

                    vim.api.nvim_create_autocmd('LspDetach', {
                        group = vim.api.nvim_create_augroup('insanum-lsp-detach', { clear = true }),
                        callback = function(event2)
                            vim.lsp.buf.clear_references()
                            vim.api.nvim_clear_autocmds { group = 'insanum-lsp-highlight', buffer = event2.buf }
                        end,
                    })
                end

                -- The following code creates a keymap to toggle inlay hints in your
                -- code, if the language server you are using supports them
                --
                -- This may be unwanted, since they displace some of your code
                if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
                    map('<leader>ih', function()
                        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
                    end, 'Toggle [I]nlay [H]ints')
                end
            end,
        })

    end,
}
