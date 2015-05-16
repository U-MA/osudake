" 倉庫番のクローン
" Version: 0.9
" Author: U-MA
" License: VIM LICENSE

if exists('g:loaded_osudake')
  finish
endif
let g:loaded_osudake = 1

let s:save_cpo = &cpo
set cpo&vim

command! Osudake call osudake#main()

let &cpo = s:save_cpo
unlet s:save_cpo
