require("Comment").setup()
require("gitsigns").setup()

require("nvim-web-devicons").setup({})

require("ibl").setup({
    indent = {},
    scope = { enabled = true },
})

require("lualine").setup({
    options = {
        theme = "catppuccin",
    },
})
