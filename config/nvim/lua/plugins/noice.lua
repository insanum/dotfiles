return {
    'folke/noice.nvim',
    enabled = true,
    event = 'VeryLazy',
    dependencies = {
        'MunifTanjim/nui.nvim',
        --[[
        {
            'rcarriga/nvim-notify',
            opts = {
                render = 'default',
                stages = 'static',
                top_down = false,
            },
        },
        --]]
    },
    opts = {
        lsp = {
            -- override markdown rendering so that other plugins use treesitter
            override = {
                ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                ["vim.lsp.util.stylize_markdown"] = true,
            },
        },
        presets = {
            bottom_search = false, -- use a classic bottom cmdline for search
            command_palette = false, -- position the cmdline and popupmenu together
            long_message_to_split = true, -- long messages will be sent to a split
            inc_rename = false, -- enables an input dialog for inc-rename.nvim
            lsp_doc_border = true, -- add a border to hover docs and signature help
        },
        messages = {
            view_search = "virtualtext",
        },
        views = {
            mini = {
                timeout = 5000,
                position = {
                    row = -3,
                },
                size = {
                    max_height = 20,
                },
                border = {
                    style = 'double',
                },
                win_options = {
                    winblend = 0,
                },
            },
        },
    },
}
