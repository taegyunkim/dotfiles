set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'gmarik/Vundle.vim'

Plugin 'google/vim-maktaba'
Plugin 'xolox/vim-misc'
" normalize async job control api for vim and neovim
Plugin 'prabirshrestha/async.vim'

" async language server protocol plugin for vim and neovim
Plugin 'prabirshrestha/vim-lsp'

" Vim appearance
Plugin 'altercation/vim-colors-solarized'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'Valloric/ListToggle'
" Plugin 'vimpostor/vim-lumen'

" File navigation
" Tree file navigation
Plugin 'scrooloose/nerdtree'
" fuzzy finder
Plugin 'kien/ctrlp.vim'
" ag frontend for vim
Plugin 'rking/ag.vim'
" Class outline viewer for vim
Plugin 'majutsushi/tagbar'
" Buffer Explorer"
Plugin 'jlanzarotta/bufexplorer'
" Related files, I miss vim-relatedfiles so much :'(
Plugin 'vim-scripts/a.vim'

" Quote/Parenthesis simple"
Plugin 'tpope/vim-surround'
Plugin 'Raimondi/delimitMate'
Plugin 'vim-scripts/Rainbow-Parenthesis'

" sessions for Vim
Plugin 'tpope/vim-obsession'

" Syntax checking
Plugin 'vim-syntastic/syntastic'
if !isdirectory('~/.dotfiles-work')
  " the ultimate autocompletion system for vim
  Plugin 'ycm-core/YouCompleteMe'
endif

" ctags plugin
Plugin 'xolox/vim-easytags'

" Language plugins
Plugin 'hdima/python-syntax'
" Plugin 'bohlender/vim-smt2'
" Plugin 'dylon/vim-antlr'
Plugin 'rust-lang/rust.vim'
" Plugin 'wlangstroth/vim-racket'
" Plugin 'vim-scripts/scribble.vim'
Plugin 'leafgarland/typescript-vim'
" Plugin 'whonore/Coqtail'

" Code Formatting
Plugin 'google/vim-codefmt'
Plugin 'syml/rust-codefmt'

" Glaive, used to configure codefmt's maktaba flags.
Plugin 'google/vim-glaive'

" Git integration
Plugin 'tpope/vim-fugitive'
Plugin 'airblade/vim-gitgutter'

call vundle#end()

call glaive#Install()
