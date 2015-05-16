" 倉庫番のクローン
" Version: 0.9
" Author: U-MA
" Lisence: VIM LISENCE

" description
"   p: player
"   P: player on a goal
"   o: object
"   O: object on a goal
"   #: wall
"   .: goal
"    : space

let s:save_cpo = &cpo
set cpo&vim

if !exists('g:osudake#enable')
  let g:osudake#enable = 1
endif

let s:osudake_dir = split(globpath(&runtimepath, 'autoload/stages'), '\n')

" vertex of player
let s:player = { 'x': 0, 'y': 0 }

function! s:player.move(dir)
  if a:dir == 'h'
    let self.x -= 1
  elseif a:dir == 'j'
    let self.y += 1
  elseif a:dir == 'k'
    let self.y -= 1
  elseif a:dir == 'l'
    let self.x += 1
  endif
endfunction

function! osudake#clear()
  execute "normal gg0"
  let x = search('o', '', line('$')-1)
  if x == 0
    return 1
  else
    return 0
  endif
endfunction

function! osudake#init(file)
  execute "new"
  for l in readfile(a:file)
    call append(line('$'), l)
  endfor
  call append(line('$'), "q for quit")
  call search('p')
  let pos = getpos('.')
  let s:player.x = pos[2]
  let s:player.y = pos[1]
endfunction

" before condition:
"   cursor points to player
"
" TODO:
"   fix in the case of 'poo'
function! osudake#moveIfPossible(dir) abort
  let nc  = ''
  let nnc = ''
  if a:dir == 'h'
    let nc  = getline('.')[s:player.x-1 - 1]
    let nnc = getline('.')[s:player.x-1 - 2]
  elseif a:dir == 'l'
    let nc  = getline('.')[s:player.x-1 + 1]
    let nnc = getline('.')[s:player.x-1 + 2]
  elseif a:dir == 'j'
    let nc  = getline(line('.')+1)[s:player.x-1]
    let nnc = getline(line('.')+2)[s:player.x-1]
  elseif a:dir == 'k'
    let nc  = getline(line('.')-1)[s:player.x-1]
    let nnc = getline(line('.')-2)[s:player.x-1]
  endif

  if nc == '#'
    " do not move
    return
  endif

  let pc = getline('.')[s:player.x - 1] " player char
  let pstr = (pc == 'p') ? "r\<space>" : "r."
  if nc == ' '
    execute "normal " . pstr . a:dir . "rp"
  elseif nc == '.'
    execute "normal " . pstr . a:dir . "rP"
  elseif nc == 'o'
    if nnc == '#'
      " do not move
      return
    elseif nnc == ' '
      execute "normal " . pstr . a:dir . "rp" . a:dir . "ro"
    elseif nnc == '.'
      execute "normal " . pstr . a:dir . "rp" . a:dir . "rO"
    endif
  elseif nc == 'O'
    if nnc == '#'
      " do not move
      return
    elseif nnc == ' '
      execute "normal " . pstr . a:dir . "rP" . a:dir . "ro"
    elseif nnc == '.'
      execute "normal " . pstr . a:dir . "rP" . a:dir . "rO"
    endif
  endif
  call s:player.move(a:dir)
endfunction

function! osudake#update(c) abort
  execute 'normal ' . s:player.y . 'G' . s:player.x . '|'
  call osudake#moveIfPossible(nr2char(a:c))
endfunction

function! osudake#main()
  call osudake#init(s:osudake_dir . "/stage1.txt")
  let c = 0
  while c != char2nr('q')
    call osudake#update(c)
    redraw
    if osudake#clear()
      echo "You did it!\nThank you for playing"
      return
    endif
    let c = getchar()
  endwhile
  echo 'Thank you for playing'
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
