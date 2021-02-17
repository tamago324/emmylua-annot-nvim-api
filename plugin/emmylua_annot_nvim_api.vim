scriptencoding utf-8

if exists('g:loaded_emmylua_annot_nvim_api')
  finish
endif
let g:loaded_emmylua_annot_nvim_api = 1

command! EmmyLuaAnnotGenMetaFile call emmylua_annot_nvim_api#gen_meta_file()
