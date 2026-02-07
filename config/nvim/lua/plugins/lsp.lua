local M = {
    name = 'lspconfig',
    setup = false,
    plug = {
        'https://github.com/neovim/nvim-lspconfig',
    },
    depends = {
        'https://github.com/williamboman/mason.nvim',
        'https://github.com/williamboman/mason-lspconfig.nvim',
    },
    priority = 50,
}

M.post_setup = function()
    local lsp_servers = {
        'clangd',
        'copilot',
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
        capabilities = require('blink.cmp').get_lsp_capabilities()
    })

    require('mason').setup()
    require('mason-lspconfig').setup({ ensure_installed = lsp_servers })
end

return M
