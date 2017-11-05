" Use Vim settings, rather than Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" indent settings
set shiftwidth=2
set tabstop=2
set softtabstop=2
set expandtab
set autoindent

" bash-like tab completion
set wildmenu wildmode=longest,list

" Use vim-plug for plugins
call plug#begin('~/.vim/bundle')
Plug 'wincent/command-t'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'mattn/flappyvird-vim'
Plug 'vim-scripts/FuzzyFinder' | Plug 'vim-scripts/L9'
Plug 'Shutnik/jshint2.vim'
Plug 'scrooloose/nerdtree'
"Plug 'shawncplus/phpcomplete.vim'
Plug 'majutsushi/tagbar'
Plug 'tpope/tpope-vim-abolish'
Plug 'bling/vim-airline'
Plug 'tpope/vim-fugitive'
Plug 'fatih/vim-go'
Plug 'tpope/vim-unimpaired'
call plug#end()

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

set history=50  " keep 50 lines of command line history
set ruler       " show the cursor position all the time
set showcmd     " display incomplete commands
set incsearch   " do incremental searching

" Use line numbers and relative numbers when available
set number
if v:version >= 704
  set relativenumber
endif

" Don't use Ex mode, use Q for formatting
map Q gq

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
endif

" We're using a 256 color terminal
set t_Co=256

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
  colorscheme slate
endif

" enable filetype-based plugins and indenting
filetype plugin indent on

" For all text files set 'textwidth' to 78 characters.
autocmd FileType text setlocal textwidth=78

" Set this after handling indenting, since the default php indenting adds it
set formatoptions-=w " don't append spaces to reformatted text

" When editing a file, always jump to the last known cursor position.
" Don't do it when the position is invalid or when inside an event handler
" (happens when dropping a file on gvim).
" Also don't do it when the mark is in the first line, that is the default
" position when opening a file.
autocmd BufReadPost *
      \ if line("'\"") > 1 && line("'\"") <= line("$") |
      \   exe "normal! g`\"" |
      \ endif

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
		  \ | wincmd p | diffthis
endif

" Map fuzzy file search to
nnoremap <C-p> :FufCoverageFile<CR>
let g:fuf_keyOpenTabpage = '<CR>'
let g:fuf_coveragefile_exclude = '\v\~$|\.o$|\.exe$|\.bak$|\.swp$|\.class$|\.html$|\.jar$|\.DS_Store$|\.zip$|\.gif$|\.png$|^dist/.*$|/compiled_views/|www/assets/scripts/|/node_modules/'

" JSHint files on save
let jshint2_save = 1


"""""""""""""""
" Status Line "
"""""""""""""""

" Always show status line
set laststatus=2
" vim-airline Status lines
let g:airline_powerline_fonts = 1
"let g:airline#extensions#tabline#enabled = 1
"function! airline#extensions#tabline#foo#format(bufnr, buffers)
"  return fnamemodify(bufname(a:bufnr), ':t')
"endfunction
"let g:airline#extensions#tabline#formatter = 'foo'


"""""""""""""
" Ctags     "
"""""""""""""

" Location of Universal Ctags executable
let s:ctags_bin = "~/ctags_build/bin/ctags"

function! ComputeCtags(...)
  execute '!php -d="display_errors=1" ' . s:ctags_bin . ' --exclude="vendor" -R > /dev/null &'
  redraw!
endfunction


"""""""""""""
" CtrlP     "
"""""""""""""

"Setup CtrlP to use Universal Ctags
let g:ctrlp_buftag_ctags_bin = s:ctags_bin


"""""""""""""
" Tagbar    "
"""""""""""""

" Setup Tagbar to use Universal Ctags
let g:tagbar_ctags_bin = s:ctags_bin

" Always use Tagbar for php files
autocmd BufEnter *.php nested TagbarOpen

" No point in keeping a Tagbar open if the file is gone
autocmd BufEnter * call CloseLoneTagbar()

function! CloseLoneTagbar()
  if &ft == "tagbar" && tabpagewinnr(tabpagenr(), '$') == 1
    if winnr() == 1
      quit
    else
      close
    endif
  endif
endfunction


"""""""""""""
" Fugitive  "
"""""""""""""

" Remake temp file dir (for long-running screen sessions & broken fugitive)
function! Greset()
  mkdir(fnamemodify(tempname(), ":p:h"))
endfunction


"""""""""""""
" Golang    "
"""""""""""""

autocmd FileType go nmap <leader>b  <Plug>(go-build)
autocmd FileType go nmap <leader>r  <Plug>(go-run)


"""""""""""""
" Filetypes "
"""""""""""""

au BufReadPost *.php setlocal shiftwidth=4 tabstop=4 softtabstop=4
au BufReadPost *.js setlocal shiftwidth=4 tabstop=4 softtabstop=4
au BufReadPost *.php.tpl setlocal filetype=php shiftwidth=4 tabstop=4 softtabstop=4

"""""""""""""
" Functions "
"""""""""""""

" Underlines the current line with the character specified as the first
" argument, or asks the user for the underine character if none given.
" Creates two lines below the underline, and moves the cursor to the 2nd.
function! Underline(...)
  " create an underline with current line's length
  let char = a:0 ? a:1 : input("underline with: ")
  " use display width to account for unicode characters
  let times = strdisplaywidth(getline(line(".")))
  let line = repeat(char,times)
  " append underline, open 2 lines below it
  call append(line("."),line)
  normal! j2o
endfunction
inoremap <D-u> <C-O>:call Underline("-")<CR>
inoremap <D-U> <C-O>:call Underline("=")<CR>
inoremap <D-¨> <C-O>:call Underline()<CR>
