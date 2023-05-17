-- File structure
---- Options grouped according to :options
---- Keybindings
---- Plugins configuration

-- 2 moving around, searching and patterns
vim.opt.wrapscan = true
vim.opt.incsearch  = true
vim.opt.smartcase = true
vim.opt.ignorecase = true

-- 4 displaying text
vim.opt.number = true
vim.opt.wrap = false
vim.opt.scrolloff = 3
vim.opt.sidescrolloff = 5
vim.opt.display = 'lastline'
vim.opt.list = true
vim.opt.listchars:append('tab:>-')

-- 5 syntax, highlighting and spelling
vim.cmd([[
    syntax on
    filetype plugin indent on
]])
vim.opt.colorcolumn = "80"
vim.opt.background = "dark"
vim.opt.spelllang = "ru,en"
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
vim.opt.completeopt = { 'menuone', 'noselect' }

-- 13 tabs and indenting
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4

-- 14 folding
vim.opt.foldenable = false

-- 16 mapping
vim.opt.timeout = true
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

-- 17 reading and writing files
vim.opt.backup = false
vim.opt.writebackup = false

-- 18 the swap file
vim.opt.directory = '/var/tmp'

-- 19 command line editing
vim.opt.history = 100
vim.opt.wildmenu = true
vim.opt.wildmode = { 'list', 'longest', 'full' }

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
    escape(ru) .. ';' .. escape(en),
    -- | `to` should be first     | `from` should be second
    escape(ru_shift) .. ';' .. escape(en_shift),
}, ',')

-- 24 various
vim.opt.signcolumn = 'yes'

-- KEY MAPPINGS
local function popup_remap(lhs, rhs)
    vim.keymap.set({ 'c', 'i' }, lhs, 
        function()
            if vim.fn.pumvisible() then
                return rhs
            else
                return lhs
            end
        end,
        { expr = true }
    )
end
popup_remap('<C-j>', '<C-n>')
popup_remap('<C-k>', '<C-p>')

--  PLUGIN STETUP
require('onedark').setup {
    style = 'darker'
}
require('onedark').load()

require('Comment').setup()

require('gitsigns').setup()

require('indent_blankline').setup()

require('lualine').setup {
    theme = 'onedark',
    transparent = false
}

require("noice").setup({
  lsp = {
    -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
    override = {
      ["cmp.entry.get_documentation"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
    },
  },
  -- you can enable a preset for easier configuration
  presets = {
    bottom_search = true, -- use a classic bottom cmdline for search
    command_palette = true, -- position the cmdline and popupmenu together
    inc_rename = false, -- enables an input dialog for inc-rename.nvim
    lsp_doc_border = false, -- add a border to hover docs and signature help
    long_message_to_split = true, -- long messages will be sent to a split
  },
})

require('trouble').setup {
}

require('telescope')
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

local actions = require("telescope.actions")
require("telescope").setup {
  defaults = {
    mappings = {
      i = {
        ["<esc>"] = actions.close
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
        }
    },
  }
}
require('telescope').load_extension('fzf')


require('cmp').setup {
    sources = {
        { name = 'nvim_lsp' }
    }
}
-- Advertise nvim-cmp LSP's capabilities to LSP server
local capabilities = require('cmp_nvim_lsp').default_capabilities()

require('nvim-treesitter.configs').setup { 
    highlight = {
        enable = true
    },
    incremental_selection = {
        enable = true 
    },
    textobjects = {
        enable = true 
    },
}

require('lspconfig').beancount.setup { }
-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', {}),
        callback = function(ev)
            -- Enable completion triggered by <c-x><c-o>
            vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

            -- Buffer local mappings.
            -- See `:help vim.lsp.*` for documentation on any of the below functions
            local opts = { buffer = ev.buf }
            vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
            vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
            vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
            vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
            vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
            vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
            vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
            vim.keymap.set('n', '<space>wl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, opts)
            vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
            vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
            vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
            vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
            vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, opts)
        end,
    })
