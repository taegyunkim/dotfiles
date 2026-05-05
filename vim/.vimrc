if !empty(glob("~/.dotfiles-work/vimrc"))
  source ~/.dotfiles-work/vimrc
endif

syntax enable
filetype plugin indent on

" General
set number
set backspace=indent,eol,start
set history=1000
set showcmd
set showmode
set visualbell
set autoread
set hidden

" Change leader to a comma
let mapleader=","

" Turn off swap and backups; persistent undo instead
set noswapfile
set nobackup
set nowritebackup
call mkdir(expand("~/.vim/backups"), "p")
set undodir=~/.vim/backups
set undofile

" Indentation
set autoindent
set smarttab
set softtabstop=2
set tabstop=2
set shiftwidth=2
set expandtab

set wrap
set linebreak
set colorcolumn=80
set textwidth=80

" Folds
set foldmethod=indent
set foldnestmax=3
set nofoldenable

" Scrolling
set scrolloff=8
set sidescrolloff=15
set sidescroll=1
set mouse=a

" Completion
set wildmenu
set wildmode=longest:full,full
set wildignore=*.o,*.obj,*~
set wildignore+=*vim/backups*
set wildignore+=*sass-cache*
set wildignore+=*DS_Store*
set wildignore+=vendor/rails/**
set wildignore+=vendor/cache/**
set wildignore+=*.gem
set wildignore+=log/**
set wildignore+=tmp/**
set wildignore+=*.png,*.jpg,*.gif

" Search
set hlsearch
set incsearch
set ignorecase
set smartcase
" Clear current search highlight by double tapping //
nmap <silent> // :nohlsearch<CR>

" turn off move down
let g:C_Ctrl_j = 'off'
let g:BASH_Ctrl_j = 'off'

" Move between split windows by using Ctrl+h,l,j,k
nnoremap <silent> <C-h> <C-w>h
nnoremap <silent> <C-l> <C-w>l
nnoremap <silent> <C-k> <C-w>k
nnoremap <silent> <C-j> <C-w>j

" Create window splits
nnoremap <silent> vv <C-w>v
nnoremap <silent> ss <C-w>s

" Move between buffers
nnoremap <silent> <C-n> :bn<CR>
nnoremap <silent> <C-p> :bp<CR>

" Copy to system clipboard
vmap <silent> <leader>y "*y

" Toggle paste mode (nvim handles bracketed paste natively)
if !has('nvim')
  set pastetoggle=<F2>
endif

" Strip trailing whitespace on save without moving the cursor
function! s:StripTrailingWhitespace()
  let l:view = winsaveview()
  keeppatterns %s/\s\+$//e
  call winrestview(l:view)
endfunction
augroup StripTrailingWhitespace
  autocmd!
  autocmd BufWritePre * call s:StripTrailingWhitespace()
augroup END

function! CopyMatches(reg)
  let hits = []
  %s//\=len(add(hits, submatch(0))) ? submatch(0) : ''/gne
  let reg = empty(a:reg) ? '+' : a:reg
  execute 'let @'.reg.' = join(hits, "\n") . "\n"'
endfunction
command! -register CopyMatches call CopyMatches(<q-reg>)
