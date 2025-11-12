
--[[
  ... tokyonight palette ...
  #f7768e #ff9e64 #e0af68 #cfc9c2 #9ece6a #73daca
  #b4f9f8 #2ac3de #7dcfff #7aa2f7 #bb9af7 #c0caf5
  #a9b1d6 #9aa5ce #565f89 #414868 #24283b #1a1b26

  ... nord palette ...
  #2e3440 #3b4252 #434c5e #4c566a
  #d8dee9 #e5e9f0 #eceff4 #ffffff
  #8fbcbb #88c0d0 #81a1c1 #5e81ac
  #bf616a #d08770 #ebcb8b #a3be8c
  #b48ead

  ... onedark palette ...
  dark
  #181a1f #282c34 #31353f #393f4a #3b3f4c #21252b
  #73b8f1 #ebd09c #abb2bf #c678dd #98c379 #d19a66
  #61afef #e5c07b #56b6c2 #e86671 #5c6370 #848b98
  #2b6f77 #993939 #93691d #8a3fa0 #31392b #382b2c
  #1c3448 #2c5372
  darker
  #0e1013 #1f2329 #282c34 #30363f #323641 #181b20
  #61afef #e8c88c #a0a8b7 #bf68d9 #8ebd6b #cc9057
  #4fa6ed #e2b86b #48b0bd #e55561 #535965 #7a818e
  #266269 #8b3434 #835d1a #7e3992 #272e23 #2d2223
  #172a3a #274964
  cool
  #151820 #242b38 #2d3343 #343e4f #363c51 #1e242e
  #6db9f7 #f0d197 #a5b0c5 #ca72e4 #97ca72 #d99a5e
  #5ab0f6 #ebc275 #4dbdcb #ef5f6b #546178 #7d899f
  #25747d #a13131 #9a6b16 #8f36a9 #303d27 #3c2729
  #18344c #265478
  deep
  #0c0e15 #1a212e #21283b #283347 #2a324a #141b24
  #54b0fd #f2cc81 #93a4c3 #c75ae8 #8bcd5b #dd9046
  #41a7fc #efbd5d #34bfd0 #f65866 #455574 #6c7d9c
  #1b6a73 #992525 #8f610d #862aa1 #27341c #331c1e
  #102b40 #1c4a6e
  warm
  #191a1c #2c2d30 #35373b #3e4045 #404247 #242628
  #79b7eb #e6cfa1 #b1b4b9 #c27fd7 #99bc80 #c99a6e
  #68aee8 #dfbe81 #5fafb9 #e16d77 #646568 #8b8d91
  #316a71 #914141 #8c6724 #854897 #32352f #342f2f
  #203444 #32526c
  warmer
  #101012 #232326 #2c2d31 #35363b #37383d #1b1c1e
  #68aee8 #e2c792 #a7aab0 #bb70d2 #8fb573 #c49060
  #57a5e5 #dbb671 #51a8b3 #de5d68 #5a5b5e #818387
  #2b5d63 #833b3b #7c5c20 #79428a #282b26 #2a2626
  #1a2a37 #2c485f
  light
  #101012 #fafafa #f0f0f0 #e6e6e6 #dcdcdc #c9c9c9
  #68aee8 #e2c792 #383a42 #a626a4 #50a14f #c18401
  #4078f2 #986801 #0184bc #e45649 #a0a1a7 #818387
  #2b5d63 #833b3b #7c5c20 #79428a #e2fbe4 #fce2e5
  #e2ecfb #cad3e0
--]]

local themes = { current = 1 }

themes.themes = {
    {
        name = 'onedark-darker',
        md_hdrs = {
            fg1 = '#cc9057',
            bg1 = '#2c485f',
            fg2 = '#8bcd5b',
            bg2 = '#2c485f',
            fg3 = '#de5d68',
            bg3 = '#2c485f',
        },
        set = function()
            vim.o.background = 'dark'
            vim.g.onedark_config = { style = 'darker' }
            vim.cmd.colorscheme 'onedark'

            require('lualine').setup({
                options = { theme = 'onedark' }
            })

            vim.cmd('hi FoobarTaskChecked guifg=#535965 gui=italic')
            vim.cmd('hi FoobarTaskPunted guifg=#535965 gui=italic,strikethrough')

            vim.cmd('hi RenderMarkdownCodeInline guifg=#8ebd6b guibg=#323641')
            vim.cmd('hi RenderMarkdownInlineHighlight guifg=#2a1b26 guibg=#d19a66')
            vim.cmd('hi @attribute guifg=#8ebd6b guibg=#323641')
            vim.cmd('hi @markup.link guifg=#5c6370 guibg=#282c34')
        end
    },

    {
        name = 'onedark-light',
        md_hdrs = {
            fg1 = '#4078f2',
            bg1 = '#c9c9c9',
            fg2 = '#50a14f',
            bg2 = '#c9c9c9',
            fg3 = '#de5d68',
            bg3 = '#c9c9c9',
        },
        set = function()
            vim.o.background = 'light'
            vim.g.onedark_config = { style = 'light' }
            vim.cmd.colorscheme 'onedark'

            require('lualine').setup({
                options = { theme = 'onedark' }
            })

            vim.cmd('hi FoobarTaskChecked guifg=#a0a1a7 gui=italic')
            vim.cmd('hi FoobarTaskPunted guifg=#a0a1a7 gui=italic,strikethrough')

            vim.cmd('hi Normal guibg=#f0f0f0')
            vim.cmd('hi CursorLine guibg=#e6e6e6')
            vim.cmd('hi ColorColumn guibg=#e6e6e6')
            vim.cmd('hi SignColumn guibg=#f0f0f0')
            vim.cmd('hi WinSeparator guifg=#383a42')
            vim.cmd('hi RenderMarkdownCodeInline guifg=#50a14f guibg=#e6e6e6')
            vim.cmd('hi RenderMarkdownInlineHighlight guifg=#101012 guibg=#e2c792')
            vim.cmd('hi @attribute guifg=#0184bc guibg=#e6e6e6')
            vim.cmd('hi @markup.link guifg=#a0a1a7 guibg=#e6e6e6')
        end
    },

    {
        name = 'tokyonight-night',
        md_hdrs = {
            fg1 = '#7aa2f7',
            bg1 = '#24283b',
            fg2 = '#9ece6a',
            bg2 = '#24283b',
            fg3 = '#de5d68',
            bg3 = '#24283b',
        },
        set = function()
            vim.o.background = 'dark'
            vim.cmd.colorscheme 'tokyonight-night'

            require('lualine').setup({
                options = { theme = 'tokyonight-night' }
            })

            vim.cmd('hi FoobarTaskChecked guifg=#565f89 gui=italic')
            vim.cmd('hi FoobarTaskPunted guifg=#565f89 gui=italic,strikethrough')

            vim.cmd('hi WinSeparator guifg=#9aa5ce')
            vim.cmd('hi TabLine guifg=#bf616a')
            vim.cmd('hi RenderMarkdownCode guibg=#24283b')
            vim.cmd('hi RenderMarkdownCodeInline guifg=#7aa2f7 guibg=#24283b')
            vim.cmd('hi RenderMarkdownInlineHighlight guifg=#1a1b26 guibg=#7dcfff')
            vim.cmd('hi @lsp.type.decorator.markdown guifg=#2ac3de guibg=#24283b')
            vim.cmd('hi @markup.link guifg=#565f89 guibg=#24283b')
            vim.cmd('hi @markup.link.label.markdown_inline guifg=#565f89 guibg=#24283b')
        end,
    },

    {
        name = 'tokyonight-day',
        md_hdrs = {
            fg1 = '#4078f2',
            bg1 = '#c9c9c9',
            fg2 = '#50a14f',
            bg2 = '#c9c9c9',
            fg3 = '#bf616a',
            bg3 = '#c9c9c9',
        },
        set = function()
            vim.o.background = 'light'
            vim.cmd.colorscheme 'tokyonight-day'

            require('lualine').setup({
                options = { theme = 'tokyonight-day' }
            })

            vim.cmd('hi FoobarTaskChecked guifg=#a9b1d6 gui=italic')
            vim.cmd('hi FoobarTaskPunted guifg=#a9b1d6 gui=italic,strikethrough')

            vim.cmd('hi WinSeparator guifg=#4c566a')
            vim.cmd('hi TabLine guifg=#414868')
            vim.cmd('hi CursorLine guibg=#d8dee9')
            vim.cmd('hi ColorColumn guibg=#d8dee9')
            vim.cmd('hi IncSearch guifg=#1a1b26 guibg=#e0af68')
            vim.cmd('hi Search guibg=#7dcfff')
            vim.cmd('hi MiniCursorword guibg=#eceff4')
            vim.cmd('hi RenderMarkdownBullet guifg=#7aa2f7')
            vim.cmd('hi RenderMarkdownCodeInline guifg=#50a14f guibg=#d8dee9')
            vim.cmd('hi RenderMarkdownInlineHighlight guifg=#2a1b26 guibg=#e0af68')
            vim.cmd('hi @lsp.type.decorator.markdown guifg=#bf616a guibg=#cad3e0')
            vim.cmd('hi @markup.link guifg=#9aa5ce guibg=#d8dee9')
            vim.cmd('hi @markup.link.label.markdown_inline guifg=#9aa5ce guibg=#d8dee9')
        end,
    },
}

local function update_markdown_headers()
    local md_hdrs = themes.themes[themes.current].md_hdrs
    if md_hdrs then
        vim.cmd('hi! RenderMarkdownH1Fg guifg=' .. md_hdrs.fg1)
        vim.cmd('hi! RenderMarkdownH2Fg guifg=' .. md_hdrs.fg2)
        vim.cmd('hi! RenderMarkdownH3Fg guifg=' .. md_hdrs.fg3)
        for i = 4, 8 do
            vim.cmd('hi! link RenderMarkdownH' .. i .. 'Fg ' ..
                    'RenderMarkdownH1Fg')
        end

        vim.cmd('hi! RenderMarkdownH1Bg guibg=' .. md_hdrs.bg1)
        vim.cmd('hi! RenderMarkdownH2Bg guibg=' .. md_hdrs.bg3)
        vim.cmd('hi! RenderMarkdownH3Bg guibg=' .. md_hdrs.bg3)
        for i = 4, 8 do
            vim.cmd('hi! link RenderMarkdownH' .. i .. 'Bg ' ..
                    'RenderMarkdownH1Bg')
        end

        vim.cmd('hi! @markup.heading.1.markdown guifg=' .. md_hdrs.fg1)
        vim.cmd('hi! @markup.heading.2.markdown guifg=' .. md_hdrs.fg2)
        vim.cmd('hi! @markup.heading.3.markdown guifg=' .. md_hdrs.fg3)
        for i = 4, 6 do
            vim.cmd('hi! @markup.heading.' .. i .. '.markdown ' ..
                    'guifg=' .. md_hdrs.fg1)
        end
    end
end

local function theme_override_all()
    vim.cmd('hi BlinkCmpMenuBorder guifg=#e16d77')
    vim.cmd('hi BlinkCmpSignatureHelpBorder guifg=#e16d77')
end

local function theme_markdown_fix()
    -- render-markdown needs to re-init after a theme change
    --vim.cmd('Lazy reload render-markdown.nvim')
    vim.cmd('DepsUpdateOffline! render-markdown.nvim')
    local file_types = {
        'markdown',
        'copilot-chat',
        'codecompanion',
        'Avante',
    }
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(bufnr) then
            local buf_filetype = vim.api.nvim_buf_get_option(bufnr, 'filetype')
            for _, ft in pairs(file_types) do
                if buf_filetype == ft then
                    vim.api.nvim_buf_call(bufnr, function()
                        vim.cmd('filetype detect') -- This does it!
                    end)
                end
            end
        end
    end
end

local function theme_set()
    themes.themes[themes.current].set()
    theme_override_all()
    update_markdown_headers()

    theme_markdown_fix()
    vim.notify(themes.themes[themes.current].name, vim.log.levels.INFO)
end

vim.keymap.set('n', '<leader>T', function()
    if vim.v.count == 0 then
        themes.current = ((themes.current % #themes.themes) + 1)
    else
        if vim.v.count > #themes.themes then
            vim.notify("Invalid theme ID (max=" .. #themes.themes .. ")",
                       vim.log.levels.ERROR)
            return
        end

        themes.current = vim.v.count
    end

    theme_set()
end, { desc = "[T]heme change" })

vim.api.nvim_create_autocmd('VimEnter', {
    callback = function()
        themes.themes[themes.current].set()
        theme_override_all()
        update_markdown_headers()
    end
})

