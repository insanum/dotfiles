
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

-- update yaml frontmatter on markdown files when saving
vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
    pattern = '*.md',
    callback = function()
        local bufnr = vim.api.nvim_get_current_buf()

        -- bail if buffer hasn't been modified
        if not vim.api.nvim_buf_get_option(bufnr, 'modified') then
            return
        end

        -- bail if buffer isn't of type markdown
        if vim.bo.filetype ~= 'markdown' then
            return
        end

        -- get the lines for this buffer
        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

        -- get the current date and time
        local updated_time = os.date('%Y-%m-%dT%H:%M')
        local created_time = updated_time

        -- helper to replace the lines in the buffer
        local function set_buf_lines(new_lines)
            vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, new_lines)
        end

        -- helper to create a default yaml frontmatter block
        local function default_frontmatter()
            return {
                '---',
                'created: ' .. created_time,
                'updated: ' .. updated_time,
                '---',
            }
        end

        -- detect if the yaml frontmatter exists or not
        if #lines == 0 or lines[1] ~= '---' then
            -- no yaml frontmatter, create it with the updated time
            local new_lines = vim.list_extend(default_frontmatter(), lines)
            set_buf_lines(new_lines)
            return
        end

        -- find the end of the yaml frontmatter
        local frontmatter_end = nil
        for i = 2, #lines do
            if lines[i] == '---' then
                frontmatter_end = i
                break
            end
        end
        -- if not found then frontmater is malformed, bail
        if not frontmatter_end then
            return
        end

        -- attributre found flags
        local found_created = false
        local created_index = 0
        local found_updated = false

        -- update or insert the attributes
        for i = 2, frontmatter_end - 1 do
            if lines[i]:match('^created:') then
                found_created = true
                created_index = i
            elseif lines[i]:match('^updated:') then
                found_updated = true
                lines[i] = 'updated: ' .. updated_time
            end
        end

        if not found_created then
            table.insert(lines, 2, 'created: ' .. created_time)
            created_index = 2
        end

        if not found_updated then
            table.insert(lines, created_index + 1, 'updated: ' .. updated_time)
        end

        set_buf_lines(lines)
    end,
})

