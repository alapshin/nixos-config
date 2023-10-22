require('Comment').setup()
require('gitsigns').setup()

require('shade').setup({})
require('nvim-web-devicons').setup({})

require('ibl').setup({
  scope = {
    show_start = false,
    highlight = { "SpecialKey", "SpecialKey", "SpecialKey" },
  },
})

require('lualine').setup({
  theme = 'github_light',
})

require('bufferline').setup({
  options = {
    separator_style = 'slant',
    always_show_bufferline = false,
  },
})
