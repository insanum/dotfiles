return {
    'ThePrimeagen/git-worktree.nvim',
    event = 'VeryLazy',
    config = function()
        --vim.g.git_worktree_log_level = 'debug'
        require('git-worktree').setup({
            change_directory_command = 'tcd',
            update_on_change_command = 'Telescope find_files',
            --autopush = true,
        })
        require('telescope').load_extension('git_worktree')
        vim.keymap.set('n', '<leader>hw', '<cmd>Telescope git_worktree<CR>', { desc = 'git Worktree switch' })
        vim.keymap.set('n', '<leader>hW', require('telescope').extensions.git_worktree.create_git_worktree, { desc = 'git Worktree create' })
    end,
}
