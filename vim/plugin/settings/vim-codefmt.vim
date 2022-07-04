map <leader>f :FormatCode<CR>

augroup autoformat_settings
	autocmd FileType javascript,typescript AutoFormatBuffer prettier
augroup END
