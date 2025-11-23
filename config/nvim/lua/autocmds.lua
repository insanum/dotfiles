
-- highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking (copying) text',
    group = vim.api.nvim_create_augroup('insanum-yank', { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})

-- I like cinoptions! (autoformatting plugins are so annoying)
vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufReadPost' }, {
    pattern = { '*.c', '*.h', '*.cc', '*.cpp', '*.ino', },
    callback = function()
        vim.opt.cindent = true
        vim.opt.indentexpr = nil
        vim.opt.cinoptions = 's,e0,n0,f0,{0,}0,^0,:0,=s,gs,hs,ps,t0,+s,c1,(0,us,)20,*30,Ws'
        vim.opt.comments = 'sO:* -,mO:*  ,exO:*/,s1:/*,mb:*,ex:*/,:///,://'
    end
})

