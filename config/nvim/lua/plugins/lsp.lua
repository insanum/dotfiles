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
    -- default        -> installed via Mason AND auto-enabled
    -- enable = false -> NOT enabled, NOT installed (uninstalled if present)
    local lsp_servers = {
        { 'clangd' },
        { 'copilot', enable = false },
        { 'rust_analyzer' },
        { 'bashls' },
        { 'pyright' },
        { 'ts_ls' },
        { 'zls' },
        { 'lua_ls' },
        -- { 'marksman' },
        { 'markdown_oxide' },
    }

    -- Split into the servers we want (install + enable) and the ones we
    -- explicitly don't (uninstall if Mason has them lying around).
    local enabled = {}
    local disabled = {}
    for _, server in ipairs(lsp_servers) do
        if server.enable == false then
            table.insert(disabled, server[1])
        else
            table.insert(enabled, server[1])
        end
    end

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
    require('mason-lspconfig').setup({
        -- Only install and auto-enable the servers we actually want.
        ensure_installed = enabled,
        automatic_enable = enabled,
    })

    -- Actively uninstall any server flagged "enable = false" so it never
    -- lingers on disk. Mason names differ from lspconfig names
    -- (e.g. copilot -> copilot-language-server), so map them first.
    if #disabled > 0 then
        local registry = require('mason-registry')
        local to_package = require('mason-lspconfig.mappings').get_mason_map().lspconfig_to_package
        for _, name in ipairs(disabled) do
            local pkg = to_package[name]
            if pkg and registry.is_installed(pkg) then
                vim.notify('Uninstalling disabled LSP server: ' .. pkg)
                registry.get_package(pkg):uninstall()
            end
        end
    end
end

return M
