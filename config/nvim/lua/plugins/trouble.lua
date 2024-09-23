return {
    "folke/trouble.nvim",
    opts = {
        focus = true,
    },
    cmd = "Trouble",
    keys = {
        {
            "<leader>xx",
            "<cmd>Trouble diagnostics toggle win.type=split win.position=bottom win.relative=win<cr>",
            desc = "Diagnostics (Trouble)",
        },
        {
            "<leader>xt",
            "<cmd>Trouble todo toggle win.type=split win.position=bottom win.relative=win<cr>",
            desc = "Todos (Trouble)",
        },
    },
}
