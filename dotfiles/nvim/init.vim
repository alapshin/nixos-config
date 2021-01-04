" Neovim configuration file
" File structure
" 1. Plugins configuration
" 2. Core vim options grouped according to :options
" 3. Plugin-specif options
" 4. Keybinding configuration

" plugins {{{
if empty(glob("~/.local/share/nvim/site/autoload/plug.vim"))
  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin("~/.local/share/nvim/plugged")
Plug 'fneu/breezy'
Plug 'itchyny/lightline.vim'
Plug 'jamessan/vim-gnupg'
Plug 'justinmk/vim-sneak'
Plug 'kien/ctrlp.vim'
Plug 'kien/rainbow_parentheses.vim'
Plug 'lervag/vimtex'
Plug 'Lokaltog/vim-easymotion'
Plug 'sheerun/vim-polyglot'
Plug 'takac/vim-hardtime'
Plug 'tomtom/tcomment_vim'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-vinegar'
Plug 'tpope/vim-unimpaired'
Plug 'vim-pandoc/vim-pandoc'
Plug 'vim-pandoc/vim-pandoc-syntax'
call plug#end()
" }}}

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
autocmd FileType tex setlocal shiftwidth=4 tabstop=4 expandtab
autocmd FileType snippet setlocal shiftwidth=8 tabstop=8 softtabstop=0 noexpandtab
autocmd FileType gitconfig setlocal shiftwidth=8 tabstop=8 softtabstop=0 noexpandtab
" remove trailing spaces
autocmd FileType c,cpp,cfg,cmake,lua,tex,css,html,xml,js,pandoc,python autocmd BufWritePre <buffer> :%s/\s\+$//e
" jinja
autocmd BufNewFile,BufRead *.j2 set filetype=jinja
autocmd BufNewFile,BufRead *.j2 set commentstring={#%s#}
" }}}

" plugins {{{

" CtrlP
let g:ctrlp_open_new_file = 'r'
let g:ctrlp_open_multiple_files = 'i'
let g:ctrlp_match_window_reversed = 0
let g:ctrlp_clear_cache_on_exit = 0
let g:ctrlp_cache_dir = $HOME.'/.cache/ctrlp'
let g:ctrlp_root_markers = ['framework']
let g:ctrlp_custom_ignore = '\vbuild.*'

" Gist
let g:gist_post_private = 1
let g:gist_show_privates = 1

" Lightline
let g:lightline = {
  \ 'colorscheme': 'breezy',
  \ }

" Polyglot
" Disable LaTeX-Box
let g:polyglot_disabled = ['latex']

" maps
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
" show CtrlP buffer list
nmap <C-O> :<C-U>CtrlPBuffer<CR>

" abbrevs {{{
" open help in vertical window
cabbrev h vertical topleft h
" }}}
