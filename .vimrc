set encoding=UTF-8

" File encoding
set fileencoding=utf-8

" Disable highlight on search
set nohlsearch

" Disable compatibility with vi which can cause unexpected issues.
set nocompatible

" Enable type file detection. Vim will be able to try to detect the type of file in use.
filetype on

" Enable plugins and load plugin for the detected file type.
filetype plugin on

" Load an indent file for the detected file type.
filetype indent on

" Turn syntax highlighting on.
syntax on

" Add numbers to each line on the left-hand side.
set number

" Use relative line numbers
set relativenumber

" Set shift width to 4 spaces.
set shiftwidth=4

" Set tab width to 4 columns.
set tabstop=4

" Use space characters instead of tabs.
set expandtab

" Do not save backup files.
set nobackup

" Disable swap files permanently
set noswapfile

" Do not let cursor scroll below or above N number of lines when scrolling.
set scrolloff=10

" Do not wrap lines. Allow long lines to extend as far as the line goes.
set nowrap

" While searching though a file incrementally highlight matching characters as you type.
set incsearch

" Ignore capital letters during search.
set ignorecase

" Show partial command you type in the last line of the screen.
set showcmd

" Show the mode you are on the last line.
set showmode

" Show matching words during a search.
set showmatch

" Use highlighting when doing a search.
set hlsearch

" Set the commands to save in history default number is 20.
set history=1000

" Enable auto completion menu after pressing TAB.
set wildmenu

" Make wildmenu behave like similar to Bash completion.
" set wildmode=list:longest

" Set path for viminfo file
set viminfofile=$XDG_STATE_HOME/vim/viminfo

" Search down into subfolders
set path+=**

" Command line height
set cmdheight=1

" Show buffers as tabs at top
set showtabline=2

" function to list buffers in tabline
function! MyTabLine()
  let s = ''
  let current = bufnr('%')
  for i in range(1, bufnr('$'))
    if buflisted(i)
      let s .= (i == current ? '%#TabLineSel#' : '%#TabLine#')
      let name = fnamemodify(bufname(i), ':t')
      let s .= ' ' . (name == '' ? '[No Name]' : name) . ' '
      if getbufvar(i, '&modified')
        let s .= '[+] '
      endif
    endif
  endfor
  let s .= '%#TabLineFill#'
  return s
endfunction

set tabline=%!MyTabLine()

" =============
" Key mappings
" =============

" Set leader key
let mapleader = " "
let maplocalleader = " "

" Disable the spacebar key's default behavior in Normal and Visual modes
nnoremap <Space> <Nop>
vnoremap <Space> <Nop>

imap jj <Esc>

" delete single character without copying into register
nnoremap x "_x

xnoremap K :move '<-2<CR>gv-gv
xnoremap J :move '>+1<CR>gv-gv

" Find and center
nnoremap n nzzzv
nnoremap N Nzzzv

" clear highlights
nnoremap <Esc> :noh<CR>

" Navigate buffers
nnoremap <Tab> :bnext<CR>
nnoremap <S-Tab> :bprevious<CR>
nnoremap <leader><leader> :buffers<CR>:buffer<Space>
nnoremap <leader>x :bdelete<CR>
nnoremap <leader>b :enew<CR>

" Navigate between splits
nnoremap <C-k> :wincmd k<CR>
nnoremap <C-j> :wincmd j<CR>
nnoremap <C-h> :wincmd h<CR>
nnoremap <C-l> :wincmd l<CR>

