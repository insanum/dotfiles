return {
    'nvim-lualine/lualine.nvim',
    enabled = true,
    event = 'VimEnter',
    config = function()
        -- with lots of splits, make sure the filenames stand out
        local fn_color = { fg = '#15161e', bg = '#ff9e64' }

        require('lualine').setup({
            options = {
                theme = 'tokyonight',
            },
            sections = {
                lualine_b = {
                    { 'branch' },
                    {
                      'diff',
                      colored = false,
                      source = function()
                          local s = vim.b.minidiff_summary
                          if s == nil then
                              return { }
                          else
                              return {
                                  added = s.add,
                                  modified = s.change,
                                  removed = s.delete,
                              }
                          end
                      end
                    },
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
