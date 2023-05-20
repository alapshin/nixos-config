require('noice').setup({
  lsp = {
    -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
    override = {
      ['cmp.entry.get_documentation'] = true,
      ['vim.lsp.util.stylize_markdown'] = true,
      ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
    },
  },
  presets = {
    bottom_search = false, -- use a classic bottom cmdline for search
    command_palette = false, -- position the cmdline and popupmenu together
    inc_rename = true, -- enables an input dialog for inc-rename.nvim
    lsp_doc_border = false, -- add a border to hover docs and signature help
    long_message_to_split = true, -- long messages will be sent to a split
  },
})
