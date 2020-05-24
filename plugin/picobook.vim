function! GrepNotes(query)
  execute 'vimgrep! /\c' . a:query . '/j ' . g:notesdir . '**/*.md'
endfunction

function CharUnderCursor()
  return strcharpart(getline('.')[col('.') - 1:], 0, 1)
endfunction

function CreateParentDir(filepath)
  let dirpath = fnamemodify(a:filepath, ':h')
  if !filereadable(dirpath)
    call system('mkdir ' . dirpath)
  endif
endfunction

function GoTo(opencommand)
  if expand('%:t') !=# 'index.md'
    " echoerr 'Command invalid outside index page'
    return 1
  endif
  if CharUnderCursor() !=# '('
    execute 'normal! f('
  endif
  let note_file = g:notesdir . expand('<cfile>')
  call CreateParentDir(note_file)
  execute a:opencommand . note_file
endfunction

command! GoToIndex :execute 'edit' g:notesdir . 'index.md'
command! -nargs=* GrepPicoNotes :call GrepNotes(<f-args>)
command! -bang -nargs=* GrepNotesFzf
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --color=always --smart-case -- '.shellescape(<q-args>), 1,
  \   fzf#vim#with_preview({'dir': g:notesdir}), <bang>0)

nnoremap <silent> <Leader>ww :GoToIndex<CR>
nnoremap <silent> <Leader>wf :call GoTo('edit')<CR>
nnoremap <silent> <Leader>wt :call GoTo('tabe')<CR>
nnoremap <silent> <Leader>wv :call GoTo('vs')<CR>
nnoremap <silent> <Leader>wx :call GoTo('sp')<CR>
nnoremap <silent> <Leader>wg :GrepNotesFzf<CR>
