return {
    'folke/tokyonight.nvim',
    priority = 1000,
    opts = {
        on_colors = function(colors)
            --colors.bg = '#0b0b0b'
        end
    },
    init = function()
        -- 'night', 'storm', 'moon', 'day'
        vim.cmd.colorscheme 'tokyonight-night'
        vim.cmd.hi 'Comment gui=none'
    end,
}
