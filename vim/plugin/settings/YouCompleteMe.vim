let g:ycm_confirm_extra_conf = 0

let g:ycm_always_populate_location_list = 1

let g:ycm_language_server = [
  \   { 'name': 'scala',
  \     'filetypes': [ 'scala' ],
  \     'cmdline': [ 'metals' ],
  \     'project_root_files': [ 'build.sbt' ]
  \   },
  \ ]
