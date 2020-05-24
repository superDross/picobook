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

function GetNoteFileName()
  if expand('%:t') !=# 'index.md'
    " echoerr 'Command invalid outside index page'
    return 1
  endif
  if CharUnderCursor() !=# '('
    execute 'normal! f('
  endif
  return g:notesdir . expand('<cfile>')
endfunction

function DeleteNoteFile()
  let note_file = GetNoteFileName()
  let answer = input('Delete file? (y/n):  ')
  if answer ==# 'y'
    call system('rm ' . note_file)
  endif
endfunction

function GoToNoteFile(opencommand)
  let note_file = GetNoteFileName()
  call CreateParentDir(note_file)
  execute a:opencommand . note_file
endfunction

command! GoToIndex :execute 'edit' g:notesdir . 'index.md'
command! -nargs=* GrepPicoNotes :call GrepNotes(<f-args>)
command! -bang -nargs=* GrepNotesFzf
  \ call fzf#vim#grep(
  \   'rg --type md --column --line-number --no-heading --color=always --smart-case -- '.shellescape(<q-args>), 1,
  \   fzf#vim#with_preview({'dir': g:notesdir}), <bang>0)

nnoremap <silent> <Leader>ww :GoToIndex<CR>
nnoremap <silent> <Leader>wf :call GoToNoteFile('edit')<CR>
nnoremap <silent> <Leader>wt :call GoToNoteFile('tabe')<CR>
nnoremap <silent> <Leader>wv :call GoToNoteFile('vs')<CR>
nnoremap <silent> <Leader>wx :call GoToNoteFile('sp')<CR>
nnoremap <silent> <Leader>wd :call DeleteNoteFile()<CR>
nnoremap <silent> <Leader>wg :GrepNotesFzf<CR>
