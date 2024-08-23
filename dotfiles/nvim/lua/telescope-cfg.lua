require("telescope")

local actions = require("telescope.actions")
require("telescope").setup({
    defaults = {
        mappings = {
            i = {
                ["<esc>"] = actions.close,
            },
        },
        extensioons = {
            fzf = {
                -- false will only do exact matching
                fuzzy = true,
                -- override the file sorter
                override_file_sorter = true,
                -- override the generic sorter
                override_generic_sorter = true,
            },
        },
    },
})
require("telescope").load_extension("fzf")

local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
vim.keymap.set("n", "<leader>fh", builtin.help_tags, {})
