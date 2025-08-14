
-- I like cinoptions! (autoformatting plugins are so annoying)
vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufReadPost' }, {
    pattern = { '*.c', '*.h', '*.cc', '*.cpp', '*.ino',
                '*.cs', '*.java', '*.js', '*.lua', '*.rs' },
    callback = function()
        vim.opt.cindent = true
        vim.opt.indentexpr = nil
        vim.opt.cinoptions = 's,e0,n0,f0,{0,}0,^0,:0,=s,gs,hs,ps,t0,+s,c1,(0,us,)20,*30,Ws'
    end
})

