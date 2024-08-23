require("inc_rename").setup({})
vim.keymap.set("n", "<leader>rn", ":IncRename ")

local lspzero = require("lsp-zero")

lspzero.on_attach(function(client, bufnr)
    lspzero.default_keymaps({
        buffer = bufnr,
        preserve_mappings = false,
    })
end)

local lspconfig = require("lspconfig")

lspconfig.lua_ls.setup({
    settings = {
        Lua = {
            runtime = {
                version = "LuaJIT",
            },
            diagnostics = {
                -- Get the language server to recognize the `vim` global
                globals = { "vim" },
            },
            workspace = {
                -- Make the server aware of Neovim runtime files
                library = vim.api.nvim_get_runtime_file("", true),
                checkThirdParty = false,
            },
            -- Do not send telemetry data containing a randomized but unique identifier
            telemetry = {
                enable = false,
            },
        },
    },
})

lspconfig.nil_ls.setup({})

lspconfig.ltex.setup({
    settings = {
        ltex = {
            enabled = {
                "markdown",
                "plaintex",
                "tex",
            },
        },
    },
})
