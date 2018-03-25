set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'gmarik/Vundle.vim'

Plugin 'xolox/vim-misc'

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
Plugin 'scrooloose/syntastic'
if !isdirectory('~/.dotfiles-work')
  " the ultimate autocompletion system for vim
  Plugin 'Shougo/neocomplcache.vim'
endif

" Go plugin
Plugin 'fatih/vim-go'

call vundle#end()
