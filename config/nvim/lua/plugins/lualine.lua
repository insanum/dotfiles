local M = {
    name = 'lualine',
    plug = {
        'https://github.com/nvim-lualine/lualine.nvim',
    },
    priority = 3,
}

-- with lots of splits, make sure the filenames stand out
local fn_color = { fg = '#15161e', bg = '#ff9e64' }

M.opts = {
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
}

return M
