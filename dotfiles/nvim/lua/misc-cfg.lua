require('Comment').setup()
require('gitsigns').setup()

require('shade').setup({})
require('nvim-web-devicons').setup({})

require('lualine').setup({
  theme = 'github_light',
})

require('bufferline').setup({
  options = {
    separator_style = 'slant',
    always_show_bufferline = false,
  },
})

require('indent_blankline').setup({
  show_current_context = true,
})
