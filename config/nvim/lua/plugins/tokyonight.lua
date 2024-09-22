return {
    'folke/tokyonight.nvim',
    priority = 1000,
    init = function()
        -- 'tokyonight-storm', 'tokyonight-moon', 'tokyonight-day'.
        vim.cmd.colorscheme 'tokyonight-night'
        vim.cmd.hi 'Comment gui=none'
    end,
}
