map <leader>f :FormatCode<CR>

augroup autoformat_settings
  autocmd FileType javascript,typescript,toml AutoFormatBuffer prettier
augroup END
