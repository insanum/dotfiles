-- Markdown-specific utilities and commands

-- register markdown filetype autocmd
vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'markdown' },
    callback = function()
        vim.opt.spell = true
        vim.opt.colorcolumn = ''
        vim.opt.wrap = true
        vim.opt.linebreak = true
        vim.opt.textwidth = 0
        vim.opt.wrapmargin = 0
        vim.opt.formatoptions:remove('l')
        vim.opt.formatlistpat = '^\\s*\\d\\+\\.\\s\\+\\|^\\s*-\\s\\+'
        vim.opt.breakindentopt = 'list:-1'

        vim.keymap.set('n', 'j', 'v:count == 0 ? "gj" : "j"',
                       { expr = true, noremap = true })
        vim.keymap.set('n', 'k', 'v:count == 0 ? "gk" : "k"',
                       { expr = true, noremap = true })

        vim.keymap.set('n', 'gf',
                       '<cmd>Pick lsp scope=\'definition\'<CR>',
                       { desc = 'Edit file under cursor', noremap = true })
    end
})

-- Clear all table cells except first column in visual selection
local function clear_table_except_first_column()
    local start_row = vim.fn.line("'<")
    local end_row = vim.fn.line("'>")

    local lines = vim.api.nvim_buf_get_lines(0, start_row - 1, end_row, false)
    local new_lines = {}

    for _, line in ipairs(lines) do
        if not line:match('^%s*|') then
            table.insert(new_lines, line)
            goto continue
        end

        local pipe_positions = {}
        local i = 1
        while i <= #line do
            if line:sub(i, i) == '|' then
                table.insert(pipe_positions, i)
            end
            i = i + 1
        end

        if #pipe_positions < 2 then
            table.insert(new_lines, line)
            goto continue
        end

        local new_line = line

        for j = 2, #pipe_positions - 1 do
            local start_pos = pipe_positions[j] + 1
            local end_pos = pipe_positions[j + 1] - 1

            local spaces = string.rep(' ', end_pos - start_pos + 1)
            new_line = new_line:sub(1, start_pos - 1) .. spaces ..
                       new_line:sub(end_pos + 1)
        end

        table.insert(new_lines, new_line)

        ::continue::
    end

    vim.api.nvim_buf_set_lines(0, start_row - 1, end_row, false, new_lines)
end

-- register commands

vim.api.nvim_create_user_command(
    'ClearTableCells', clear_table_except_first_column, {
    range = true,
    desc = 'Clear all table cells except first column in visual selection'
})

