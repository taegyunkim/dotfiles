let g:ctrlp_map = ',p'
nnoremap <silent> ,p :CtrlP<CR>
let g:ctrlp_working_path_mode = 'a'

let g:ctrlp_user_command = 'ag %s -i --nocolor --nogroup --hidden
      \ --ignore .git
      \ --ignore .svn
      \ --ignore .hg
      \ --ignore .DS_Store
      \ --ignore "**/*.pyc"
      \ --ignore .git5_specs
      \ --ignore review
      \ -g ""'
