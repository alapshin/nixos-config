local nls = require('null-ls')
nls.setup({
  sources = {
    nls.builtins.code_actions.shellcheck,
    nls.builtins.code_actions.statix,
    nls.builtins.diagnostics.gitlint,
    nls.builtins.diagnostics.hadolint,
    nls.builtins.diagnostics.selene,
    nls.builtins.diagnostics.shellcheck,
    nls.builtins.diagnostics.statix,
    nls.builtins.formatting.alejandra,
  },
})
