local M = {
    name = 'nvim-treesitter.configs',
    plug = {
        'https://github.com/nvim-treesitter/nvim-treesitter',
    },
    priority = 5,
}

M.pre_pack_add = function()
    local treesitter_hook = function(ev)
        local name, kind = ev.data.spec.name, ev.data.kind
        if name == 'treesitter' and kind == 'install' then
            vim.cmd('TSUpdate')
        end
    end

    vim.api.nvim_create_autocmd('PackChanged', {
        callback = treesitter_hook,
        once = true,
    })
end

M.opts = {
    ensure_installed = {
        'bash',
        'c',
        'html',
        'lua',
        'markdown',
        'markdown_inline',
        'vim',
        'vimdoc',
        'javascript',
        'rust',
        'python',
        'zig',
    },
    auto_install = true,
    highlight = { enable = true },
    indent = { enable = false }, -- This completely F's cinoptions...
}

return M
