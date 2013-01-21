" TODO: Move these mappings elsewhere.
nnoremap <silent> <Leader>gg :set operatorfunc=<SID>MyGrepOperator<CR>g@
vnoremap <silent> <Leader>gg :<C-u>call <SID>MyGrepOperator(visualmode())<CR>

nnoremap <silent> ]g :call <SID>MyGrepReplaceNext()<CR>
nnoremap <silent> [g :call <SID>MyGrepReplacePrevious()<CR>
nnoremap <silent> <Leader>gr :call <SID>SetNewGrepString()<CR>
nnoremap <silent> <Leader>ga :call <SID>MyGrepReplaceAll()<CR>
nnoremap <silent> <Leader>r :call <SID>MyGrepReplace()<CR>

function! s:MyGrepReplaceAll()
  if !<SID>GrepHasRun()
    return
  endif

  silent! cc 1
  for item in s:grepped_items_list
    try
      call <SID>MyGrepReplace()
      silent! cnext
    catch /^Vim:Interrupt$/
      let l:maybe_quit = input("Quit? (y/n) > ")
      if l:maybe_quit ==? 'y'
        break
      endif
    endtry
  endfor
endfunction

function! s:MyGrepReplaceNext()
  if !<SID>GrepHasRun()
    return
  endif

  silent! cnext
  call <SID>MyGrepReplace()
endfunction

function! s:MyGrepReplacePrevious()
  if !<SID>GrepHasRun()
    return
  endif

  silent! cprev
  call <SID>MyGrepReplace()
endfunction

function! s:MyGrepOperator(type)
  let l:current_buffer = winnr()
  if a:type ==# 'char'
    silent execute "normal! `[v`]y"
  elseif a:type ==# 'v'
    silent execute "normal! `<v`>y"
  endif
  let s:current_grep_str = @@

  let l:exclude_flags = " . --exclude-dir=blaze-\\* --exclude=\\*.swp"
  let l:cmd="grep! -R " . shellescape(s:current_grep_str) . l:exclude_flags
  silent execute l:cmd
  redraw!
  botright copen
  silent execute l:current_buffer . "wincmd w"

  let s:grepped_items_list = getqflist()

  let l:filenames = {}
  for item in s:grepped_items_list
    let l:filenames[bufname(item['bufnr'])] = 1
  endfor

  let l:filenames_list = keys(l:filenames)

  redraw!
  echohl ModeMsg
  echom "Grepped: '" . s:current_grep_str . "' (" .
        \ len(s:grepped_items_list) . "X, " .
        \ len(l:filenames_list) . " file(s))"
  echohl None
endfunction

function! s:GrepHasRun()
  if !exists("s:current_grep_str")
    return 0
  elseif !exists("s:grepped_items_list")
    return 0
  elseif len(s:grepped_items_list) == 0
    return 0
  endif
  return 1
endfunction

function! s:MyGrepReplace()
  if !<SID>GrepHasRun()
    return
  endif

  if !exists("s:new_grep_str")
    call <SID>SetNewGrepString()
  endif
  let l:cmd= "s/" . s:current_grep_str. "/" . s:new_grep_str . "/gce"
  execute l:cmd
endfunction

function! s:SetNewGrepString()
  " TODO: Custom completion?
  echohl ModeMsg
  let s:new_grep_str = input("Replace " . s:current_grep_str . " with? >>")
  echohl None
endfunction

