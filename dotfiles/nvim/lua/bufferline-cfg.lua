require('bufferline').setup({
  options = {
    -- diagnostics = "nvim_lsp",
    separator_style = 'slant',
    always_show_bufferline = true,
    show_close_icon = false,
    show_buffer_close_icons = false,
    offsets = {
      {
        filetype = "neo-tree",
        text = "File Explorer",
        text_align = "left",
        highlight = "Directory",
      }
    },
  },
})
