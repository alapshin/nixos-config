" Neovim configuration file
" File structure
" 1. Core vim options grouped according to :options
" 2. Keybindings
" 3. Plugins configuration

" moving around, searching and patterns {{{
set wrapscan
set incsearch
set smartcase
set ignorecase
" }}}

" displaying text {{{
set number
set nowrap
set scrolloff=3
set sidescrolloff=5
set display+=lastline
set listchars=tab:>-
" }}}

" syntax, highlighting and spelling {{{
syntax on
filetype plugin indent on
set colorcolumn=80
set background=light
set spelllang=ru,en
set termguicolors
colorscheme breezy
let loaded_matchparen = 1
" }}}

" multiple windows {{{
set laststatus=2
set statusline=%F
set statusline+=%m
set statusline+=%=
set statusline+=[%Y,%{strlen(&fenc)?&fenc:'none'},%{&ff}]
set statusline+=\ %(%l/%L,%c%V%)\ %P
set hidden
set splitright
set splitbelow
" }}}

" GUI {{{
set guifont=Monospace:h10
set guioptions=aei
" }}}

" messages and info {{{
set shortmess+=I
" }}}

" selecting text {{{
set clipboard=unnamedplus " use X11 clipboard
" }}}

" editing text {{{
set undofile
set pumheight=12
set completeopt=longest,menuone
" }}}

" tabs and indenting {{{
set expandtab
set shiftwidth=4
set softtabstop=4
" }}}

" folding {{{
set nofoldenable
" }}}

" reading and writing files {{{
set nobackup
set nowritebackup
" }}}

" the swap file {{{
set directory=/var/tmp
" }}}

" command line editing {{{
set history=100
set wildmenu
set wildmode=list,longest,full
" }}}

" language specific {{{
set langmap=ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz
" }}}

" multi-byte characters {{{
set fileencodings=ucs-bom,utf-8,cp1251
" }}}

" autocmds {{{
autocmd FileType nix setlocal shiftwidth=2 tabstop=2 expandtab
autocmd FileType tex setlocal shiftwidth=4 tabstop=4 expandtab
autocmd FileType snippet setlocal shiftwidth=8 tabstop=8 softtabstop=0 noexpandtab
autocmd FileType gitconfig setlocal shiftwidth=8 tabstop=8 softtabstop=0 noexpandtab
" remove trailing spaces
autocmd FileType c,cpp,cfg,cmake,lua,tex,css,html,xml,js,pandoc,python autocmd BufWritePre <buffer> :%s/\s\+$//e
" }}}

" keybindings {{{
" map semicolon to colon
map ; :
" Save readonly file with sudo :w!!
cmap w!! w !sudo tee > /dev/null %
" delete without yank
nmap <silent> <Leader>d "_d
vmap <silent> <Leader>d "_d
" use jj as <Esc> alternative
inoremap jj <Esc>
" make Y behave like other capitals
nnoremap Y y$
" edit/reload vim config
nmap <Leader>e :edit $MYVIMRC
nmap <Leader>s :source $MYVIMRC
" disable arrow keys
noremap <Up> <nop>
noremap <Down> <nop>
noremap <Left> <nop>
noremap <Right> <nop>
inoremap <Up> <nop>
inoremap <Down> <nop>
inoremap <Left> <nop>
inoremap <Right> <nop>
" easy split navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
" clear search register
nnoremap <silent> <Leader>h :let @/=""<cr><esc>
" find TODO and FIXME entries
nnoremap <silent> <Leader>t :noautocmd vimgrep /\CTODO\\|FIXME/j **/*.py<CR>:cw<CR>
" }}}

" abbrevs {{{
" open help in vertical window
cabbrev h vertical topleft h
" }}}
"
" plugins {{{
" {{{ fzf
nnoremap <c-p> :GFiles<CR>
nnoremap <c-o> :Buffers<CR>
" }}}
" {{{ vim-nix
let nix_recommended_style = 1
" }}}
" {{{ lightline
let g:lightline = { 'colorscheme': 'breezy', }
" }}}
" }}}

