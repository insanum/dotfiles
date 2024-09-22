return {
    'nvim-lualine/lualine.nvim',
    event = 'VimEnter',
    config = function()
        --[[
        local function show_codeium_status()
            return '{…}' .. vim.fn['codeium#GetStatusString']()
        end
        --]]

        -- with lots of splits, make sure the filenames stand out
        local fn_color = { fg = '#15161e', bg = '#ff9e64' }

        require('lualine').setup({
            options = {
                theme = 'tokyonight',
            },
            sections = {
                lualine_b = {
                    --{ show_codeium_status },
                    { 'branch' },
                    { 'diff', colored = false },
                    { 'diagnostics' },
                },
                lualine_c = {
                    { 'filename', color = fn_color },
                },
            },
            inactive_sections = {
                lualine_c = {
                    { 'filename', color = fn_color },
                },
            },
        })
    end,
}
