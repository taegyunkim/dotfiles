let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin()

function! BuildYCM(info)
  " info is a dictionary with 3 fields
  " - name:   name of the plugin
  " - status: 'installed', 'updated', or 'unchanged'
  " - force:  set on PlugInstall! or PlugUpdate!
  if a:info.status != 'unchanged' || a:info.force
    !python3 install.py --all
  endif
endfunction

if empty(glob("~/.dotfiles-work/vimrc"))
  Plug 'google/vim-maktaba'
  if has('python3')
    Plug 'ycm-core/YouCompleteMe', {'do': function('BuildYCM')}
  endif
  " Code Formatting
  Plug 'google/vim-codefmt'
  " Glaive, used to configure codefmt's maktaba flags.
  Plug 'google/vim-glaive'
  " Copilot
  " Plug 'github/copilot.vim'
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
" Plug 'lervag/vimtex'
" Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && npm install --global yarn && yarn install' }

" Git integration
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

call plug#end()
