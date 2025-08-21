
--[[
  ... tokyonight palette ...
  #f7768e  #ff9e64  #e0af68
  #cfc9c2  #9ece6a  #73daca
  #b4f9f8  #2ac3de  #7dcfff
  #7aa2f7  #bb9af7  #c0caf5
  #a9b1d6  #9aa5ce  #565f89
  #414868  #24283b  #1a1b26

  ... nord palette ...
  #2e3440  #3b4252  #434c5e  #4c566a
  #d8dee9  #e5e9f0  #eceff4  #ffffff
  #8fbcbb  #88c0d0  #81a1c1  #5e81ac
  #bf616a  #d08770  #ebcb8b  #a3be8c
  #b48ead
--]]

local themes = { current = 1 }

themes.themes = {
    {
        name = 'tokyonight-night',
        set = function()
            vim.o.background = 'dark'
            vim.cmd.colorscheme 'tokyonight-night'

            require('lualine').setup({
                options = { theme = 'tokyonight-night' }
            })

            -- split window borders
            vim.cmd('hi WinSeparator guifg=#9aa5ce')

            -- tabline text for non-focused tabs needs to stand out more
            vim.cmd('hi TabLine guifg=#bf616a')

            -- render-markdown tweaks
            vim.cmd('hi RenderMarkdownCode guibg=#24283b')
            vim.cmd('hi RenderMarkdownCodeInline guibg=#24283b')
            vim.cmd('hi RenderMarkdownInlineHighlight guifg=#1a1b26 guibg=#7dcfff')
        end,
    },

    {
        name = 'tokyonight-day',
        set = function()
            vim.o.background = 'light'
            vim.cmd.colorscheme 'tokyonight-day'

            require('lualine').setup({
                options = { theme = 'tokyonight-day' }
            })

            -- split window borders
            vim.cmd('hi WinSeparator guifg=#4c566a')

            -- tabline text for non-focused tabs needs to stand out more
            vim.cmd('hi TabLine guifg=#414868')

            -- tame down the cursor line
            vim.cmd('hi CursorLine guibg=#d8dee9')

            -- lighten up search highlighting
            vim.cmd('hi IncSearch guifg=#1a1b26 guibg=#e0af68')
            vim.cmd('hi Search guibg=#7dcfff')

            -- lighten up cursorwork highlighting
            vim.cmd('hi MiniCursorword guibg=#eceff4')

            -- render-markdown tweaks
            vim.cmd('hi RenderMarkdownCodeInline guifg=#1a1b26 guibg=#d8dee9')
            vim.cmd('hi RenderMarkdownInlineHighlight guifg=#1a1b26 guibg=#e0af68')
            vim.cmd('hi RenderMarkdownBullet guifg=#7aa2f7')
        end,
    },
}

local function theme_override_all()
    -- all comments rendered in italics
    --vim.cmd('hi Comment gui=none cterm=italic gui=italic')
end

local function theme_toggle()
    themes.current = ((themes.current % #themes.themes) + 1)
    themes.themes[themes.current].set()
    theme_override_all()
    vim.notify(themes.themes[themes.current].name, vim.log.levels.INFO)
end

vim.keymap.set('n', 'T', function() theme_toggle() end)

vim.api.nvim_create_autocmd('VimEnter', {
    callback = function()
        themes.themes[themes.current].set()
    end
})

