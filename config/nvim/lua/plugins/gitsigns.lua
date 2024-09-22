return {
    'lewis6991/gitsigns.nvim',
    opts = {
        on_attach = function(bufnr)
            local gs = package.loaded.gitsigns

            local function map(mode, l, r, opts)
                opts = opts or {}
                opts.buffer = bufnr
                vim.keymap.set(mode, l, r, opts)
            end

            -- Navigation

            map({ 'n', 'v' }, ']c',
                function()
                    if vim.wo.diff then
                        return ']c'
                    end
                    vim.schedule(function()
                        gs.next_hunk()
                    end)
                    return '<Ignore>'
                end,
                { expr = true, desc = 'Jump to next hunk' })

            map({ 'n', 'v' }, '[c',
                function()
                    if vim.wo.diff then
                        return '[c'
                    end
                    vim.schedule(function()
                        gs.prev_hunk()
                    end)
                    return '<Ignore>'
                end,
                { expr = true, desc = 'Jump to previous hunk' })

            -- Actions (visual mode)

            map('v', '<leader>hs',
                function()
                    gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
                end,
                { desc = 'stage git hunk' })

            map('v', '<leader>hr',
                function()
                    gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
                end,
                { desc = 'reset git hunk' })

            -- Actions (normal mode)

            map('n', '<leader>hs', gs.stage_hunk, { desc = 'git Stage hunk' })
            map('n', '<leader>hr', gs.reset_hunk, { desc = 'git Reset hunk' })
            map('n', '<leader>hS', gs.stage_buffer, { desc = 'git Stage buffer' })
            map('n', '<leader>hu', gs.undo_stage_hunk, { desc = 'git Undo stage hunk' })
            map('n', '<leader>hR', gs.reset_buffer, { desc = 'git Reset buffer' })
            map('n', '<leader>hp', gs.preview_hunk, { desc = 'git Preview hunk' })
            map('n', '<leader>hd', gs.diffthis, { desc = 'git Diff against index' })

            map('n', '<leader>hb',
                function()
                    gs.blame_line({ full = false })
                end,
                { desc = 'git Blame line' })

            --[[
            map('n', '<leader>hD',
                function()
                    gs.diffthis('~')
                end,
                { desc = 'git Diff against last commit' })
            --]]

            -- Toggles
            --map('n', '<leader>hB', gs.toggle_current_line_blame, { desc = 'toggle git blame line' })
            --map('n', '<leader>hL', gs.toggle_deleted, { desc = 'toggle git show deleted' })

            -- Text object
            map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'git Select hunk' })
        end,
    },
}
