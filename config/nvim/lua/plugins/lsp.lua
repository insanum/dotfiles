local M = {}

M.setup = function(add)
    add({
        source = 'neovim/nvim-lspconfig',
        depends = {
            'williamboman/mason.nvim',
            'williamboman/mason-lspconfig.nvim',
        }
    })

    local lsp_servers = {
        'clangd',
        'rust_analyzer',
        'bashls',
        'pyright',
        'ts_ls',
        'zls',
        'lua_ls',
        -- 'marksman',
        'markdown_oxide',
    }

    -- See ":help lspconfig-all" for LSP configs!

    -- Any configs tweaks via "vim.lsp.config('<server>', { ... })" must
    -- happen here before setting up mason-lspconfig since mason-lspconfig
    -- will call "vim.lsp.enable('<server>')" for each server.

    -- Neovim doesn't support everything that is in the LSP specification and
    -- blink.cmp adds more. Here the default capabilities are extended for
    -- use by all LSP servers.
    vim.lsp.config('*', {
        capabilities = require('blink.cmp').get_lsp_capabilities(),
    })

    require('mason').setup()
    require('mason-lspconfig').setup({ ensure_installed = lsp_servers, })
end

return M
