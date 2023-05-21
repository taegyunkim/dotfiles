call plug#begin()

if empty(glob("~/.dotfiles-work/vimrc"))
  Plug 'google/vim-maktaba'
endif
Plug 'xolox/vim-misc'

" Vim appearance
Plug 'altercation/vim-colors-solarized'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'Valloric/ListToggle'

" File navigation
" Tree file navigation
Plug 'scrooloose/nerdtree'
" fuzzy finder
Plug 'kien/ctrlp.vim'
" ag frontend for vim
Plug 'rking/ag.vim'
" Class outline viewer for vim
Plug 'majutsushi/tagbar'
" Buffer Explorer"
Plug 'jlanzarotta/bufexplorer'
" Related files, I miss vim-relatedfiles so much :'(
Plug 'vim-scripts/a.vim'

" Quote/Parenthesis simple"
Plug 'tpope/vim-surround'
Plug 'Raimondi/delimitMate'
Plug 'vim-scripts/Rainbow-Parenthesis'

" sessions for Vim
Plug 'tpope/vim-obsession'

function! BuildYCM(info)
  " info is a dictionary with 3 fields
  " - name:   name of the plugin
  " - status: 'installed', 'updated', or 'unchanged'
  " - force:  set on PlugInstall! or PlugUpdate!
  if a:info.status != 'unchanged' || a:info.force
    !python3 install.py --all
  endif
endfunction

" Syntax checking
" Plug 'dense-analysis/ale'

" Autocompletion
if empty("~/.dotfiles-work/vimrc")
  Plug 'ycm-core/YouCompleteMe', {'do': function('BuildYCM')}
endif

" Language plugins
Plug 'hdima/python-syntax'
" Plug 'bohlender/vim-smt2'
" Plug 'dylon/vim-antlr'
Plug 'rust-lang/rust.vim', { 'for': 'rust' }
" Plug 'wlangstroth/vim-racket'
" Plug 'vim-scripts/scribble.vim'
Plug 'leafgarland/typescript-vim'
" Plug 'whonore/Coqtail'
Plug 'memgraph/cypher.vim'
Plug 'TovarishFin/vim-solidity'
Plug 'lervag/vimtex'
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && npm install --global yarn && yarn install' }

" Code Formatting
if empty(glob("~/.dotfiles-work/vimrc"))
  Plug 'google/vim-codefmt'
endif

" Glaive, used to configure codefmt's maktaba flags.
if empty(glob("~/.dotfiles-work/vimrc"))
  Plug 'google/vim-glaive'
endif

" Git integration
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

" Github copilot
if empty(glob("~/.dotfiles-work/vimrc"))
  Plug 'github/copilot.vim'
endif

call plug#end()
