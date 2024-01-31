-- Options as in :options

-- 2 moving around, searching and patterns
vim.opt.wrapscan = true
vim.opt.incsearch = true
vim.opt.smartcase = true
vim.opt.ignorecase = true

-- 4 displaying text
vim.opt.number = true
vim.opt.wrap = false
vim.opt.scrolloff = 3
vim.opt.sidescrolloff = 5
vim.opt.display = 'lastline'
vim.opt.list = false
vim.opt.listchars = { eol = '↴', space = '·', tab = '>-' }

-- 5 syntax, highlighting and spelling
vim.cmd([[
    syntax on
    filetype plugin indent on
]])
vim.opt.colorcolumn = '80'
vim.opt.cursorline = true
vim.opt.spelllang = 'ru,en'
vim.opt.termguicolors = true

-- 6 multiple windows
vim.opt.laststatus = 2
--vim.opt.statusline = "%F"
--vim.opt.statusline.append("%m")
--vim.opt.statusline.append("%=")
--vim.opt.statusline.append("[%Y,%{strlen(&fenc)?&fenc:'none'},%{&ff}]")
--vim.opt.statusline.append(" %(%l/%L,%c%V%) %P")
vim.opt.hidden = true
vim.opt.splitright = true
vim.opt.splitbelow = true

-- 9 using the mouse
vim.opt.mouse = 'a'

-- 10 messages and info
vim.opt.shortmess:append({ I = true })

-- 11 selecting text
vim.opt.clipboard = 'unnamedplus' -- use X11 clipboard

-- 12 editing text
vim.opt.undofile = true
vim.opt.pumheight = 12
vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }

-- 13 tabs and indenting
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4

-- 14 folding
vim.opt.foldenable = false

-- 16 mapping
vim.opt.timeout = true
vim.opt.timeoutlen = 500

-- 17 reading and writing files
vim.opt.backup = false
vim.opt.writebackup = false

-- 18 the swap file
vim.opt.directory = '/var/tmp'

-- 19 command line editing
vim.opt.history = 100
vim.opt.wildmenu = true
vim.opt.wildmode = { 'longest:list', 'full' }

-- 22 language specific
local function escape(str)
  -- You need to escape these characters to work correctly
  local escape_chars = [[;,."|\]]
  return vim.fn.escape(str, escape_chars)
end
-- Recommended to use lua template string
local en = [[`qwertyuiop[]asdfghjkl;'zxcvbnm]]
local ru = [[ёйцукенгшщзхъфывапролджэячсмить]]
local en_shift = [[~QWERTYUIOP{}ASDFGHJKL:"ZXCVBNM<>]]
local ru_shift = [[ËЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ]]
vim.opt.langmap = vim.fn.join({
  -- | `to` should be first     | `from` should be second
  escape(ru)
    .. ';'
    .. escape(en),
  escape(ru_shift) .. ';' .. escape(en_shift),
}, ',')

-- 24 various
vim.opt.signcolumn = 'yes'
