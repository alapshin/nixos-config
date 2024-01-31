require("tint").setup({
    tint = -25,
    saturation = 0.25,
})

require("catppuccin").setup({
    flavour = "latte", -- latte, frappe, macchiato, mocha
    background = { -- :h background
        dark = "mocha",
        light = "latte",
    },
    term_colors = false, -- sets terminal colors (e.g. `g:terminal_color_0`)
    show_end_of_buffer = false, -- shows the '~' characters after the end of buffers
    transparent_background = false, -- disables setting the background color.
    no_bold = false, -- Force no bold
    no_italic = false, -- Force no italic
    no_underline = false, -- Force no underline
    styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
        booleans = {},
        comments = { "italic" }, -- Change the style of comments
        conditionals = { "italic" },
        functions = {},
        keywords = {},
        loops = {},
        numbers = {},
        operators = {},
        properties = {},
        strings = {},
        types = {},
        variables = {},
    },
    integrations = {
        cmp = true,
        gitsigns = true,
        noice = true,
        notify = false,
        nvimtree = true,
        telescope = {
            enabled = true,
        },
        treesitter = true,
        indent_blankline = {
            enabled = true,
            colored_indent_levels = false,
        },
        which_key = true,
    },
})


vim.opt.background = 'light'
vim.cmd('colorscheme catppuccin')
