return {
  'https://github.com/chentoast/marks.nvim',
  config = function()
    require('marks').setup {
      --builtin_marks = { ".", "<", ">", "^" },
      --sign_priority = { lower=10, upper=15, builtin=8, bookmark=20 },
    }
  end,
}
