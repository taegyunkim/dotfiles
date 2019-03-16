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
" Snippets for vim"
if v:version >= 704
  " Snippets for vim"
  Plugin 'SirVer/ultisnips'
endif

" sessions for Vim
Plugin 'tpope/vim-obsession'

" Syntax checking
Plugin 'vim-syntastic/syntastic'
if !isdirectory('~/.dotfiles-work')
  " the ultimate autocompletion system for vim
  Plugin 'Valloric/YouCompleteMe'
endif

" ctags plugin
Plugin 'xolox/vim-easytags'

" Language plugins
Plugin 'fatih/vim-go'
Plugin 'vhda/verilog_systemverilog.vim'

" Code Formatting
Plugin 'google/vim-codefmt'

" Glaive, used to configure codefmt's maktaba flags.
Plugin 'google/vim-glaive'

" Git integration
Plugin 'tpope/vim-fugitive'
Plugin 'airblade/vim-gitgutter'

call vundle#end()

call glaive#Install()
