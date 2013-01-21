" TODO: Move these mappings elsewhere.
nnoremap <silent> <Leader>gg :set operatorfunc=MyGrepOperator<CR>g@
vnoremap <silent> <Leader>gg :<C-u>call MyGrepOperator(visualmode())<CR>


nnoremap <silent> ]g :call MyGrepReplaceNext()<CR>
nnoremap <silent> [g :call MyGrepReplacePrevious()<CR>
nnoremap <silent> <Leader>gr :call SetNewGrepString()<CR>
nnoremap <silent> <Leader>ga :call MyGrepReplaceAll()<CR>
nnoremap <silent> <Leader>r :call MyGrepReplace()<CR>

function! MyGrepReplaceAll()
  if !GrepHasRun()
    return
  endif

  silent! cc 1
  for item in g:grepped_items_list
    call MyGrepReplace()
    silent! cnext
  endfor
endfunction

function! MyGrepReplaceNext()
  if !GrepHasRun()
    return
  endif

  silent! cnext
  call MyGrepReplace()
endfunction

function! MyGrepReplacePrevious()
  if !GrepHasRun()
    return
  endif

  silent! cprev
  call MyGrepReplace()
endfunction

function! MyGrepOperator(type)
  let l:current_buffer = winnr()
  if a:type ==# 'char'
    silent execute "normal! `[v`]y"
  elseif a:type ==# 'v'
    silent execute "normal! `<v`>y"
  endif
  let g:current_grep_str = @@

  let l:exclude_flags = " . --exclude-dir=blaze-\\* --exclude=\\*.swp"
  let l:cmd="grep! -R " . shellescape(g:current_grep_str) . l:exclude_flags
  let g:grepped_items_list = getqflist()
  let g:grepped_items_current_index = 0
  silent execute l:cmd
  redraw!
  botright copen
  silent execute l:current_buffer . "wincmd w"


  let l:filenames = {}
  for item in g:grepped_items_list
    let l:filenames[bufname(item['bufnr'])] = 1
  endfor

  let l:filenames_list = keys(l:filenames)

  echohl ModeMsg
  echom "Grepped: '" . g:current_grep_str . "' (" .
        \ len(g:grepped_items_list) . "X, " .
        \ len(l:filenames_list) . " file(s))"
  echohl None
endfunction

function! GrepHasRun()
  if !exists("g:current_grep_str")
    return 0
  elseif !exists("g:grepped_items_list")
    return 0
  elseif len(g:grepped_items_list) == 0
    return 0
  endif
  return 1
endfunction

function! MyGrepReplace()
  if !GrepHasRun()
    return
  endif

  if !exists("g:new_grep_string")
    call SetNewGrepString()
  endif
  let l:cmd= "s/" . g:current_grep_str. "/" . g:new_grep_string . "/gce"
  execute l:cmd
endfunction

function! SetNewGrepString()
  echohl ModeMsg | echom "Replace " . g:current_grep_str . " with ?"
  " TODO: Custom completion?
  echohl Search
  let g:new_grep_string = input(">>")
  echohl None
endfunction

