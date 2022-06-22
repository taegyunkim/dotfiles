map <leader>f :FormatCode<CR>

augroup autoformat_settings
	autocmd FileType javascript,solidity,typescript AutoFormatBuffer prettier
augroup END
