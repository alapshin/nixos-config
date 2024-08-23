local nls = require("null-ls")
nls.setup({
    sources = {
        nls.builtins.diagnostics.gitlint,
        nls.builtins.diagnostics.hadolint,
    },
})
