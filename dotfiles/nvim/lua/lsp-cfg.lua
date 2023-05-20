local lspconfig = require('lspconfig')
-- Advertise nvim-cmp LSP's capabilities to all LSP servers
local lsp_defaults = lspconfig.util.default_config
local cmp_capabilities = require('cmp_nvim_lsp').default_capabilities()
lsp_defaults.capabilities =
  vim.tbl_deep_extend('force', lsp_defaults.capabilities, cmp_capabilities)

lspconfig.lua_ls.setup({
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = { 'vim' },
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = vim.api.nvim_get_runtime_file('', true),
        checkThirdParty = false,
      },
      -- Do not send telemetry data containing a randomized but unique identifier
      telemetry = {
        enable = false,
      },
    },
  },
})
lspconfig.rnix.setup({})
lspconfig.beancount.setup({})

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    local bufnr = ev.buf
    -- Enable completion triggered by <C-x><C-o>
    vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'

    local nmap = function(keys, func, desc)
      if desc then
        desc = 'LSP: ' .. desc
      end

      vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
    end

    nmap('gd', vim.lsp.buf.definition, 'Goto Definition')
    nmap('gD', vim.lsp.buf.declaration, 'Goto Declaration')
    nmap('gr', vim.lsp.buf.references, 'Goto References')
    nmap('gi', vim.lsp.buf.implementation, 'Goto Implementation')
    nmap('<leader>td', vim.lsp.buf.type_definition, 'Type Definitions')

    nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
    nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

    nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, 'Add Workspace Folder')
    nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, 'Remove Workspace Folder')
    nmap('<leader>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, 'List Workspace Folders')

  end,
})
