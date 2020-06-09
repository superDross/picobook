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


function CheckIfInIndex()
  try
    if expand('%:t') !=# 'index.md'
      throw 'Command invalid outside index page'
    endif
  catch /.invalid outside index/
    echoerr 'Command only valid within picobook index file'
  endtry
endfunction


function ExtractPath()
  " extracts path link under cursor
  let line = getline('.')
  try
    " if startswith '-' and has brackets
    if line =~# '^-' && line =~# '(' && line =~# ')'
      return matchstr(line, '(\zs.\{-}\ze)')
    else
      throw 'not valid line'
    endif
  catch /not valid line/
    echoerr 'This line does not contain a valid link'
  endtry
endfunction


function GetNoteFileName()
  let partialPath = ExtractPath()
  return g:notesdir . partialPath
endfunction


function DeleteNoteFile()
  call CheckIfInIndex()
  let note_file = GetNoteFileName()
  let answer = input('Delete file? (y/n):  ')
  if answer ==# 'y'
    call delete(note_file)
  endif
endfunction


function GoToNoteFile(opencommand)
  call CheckIfInIndex()
  let note_file = GetNoteFileName()
  call CreateParentDir(note_file)
  execute a:opencommand . note_file
endfunction


function GoToNoteWebPage()
  call CheckIfInIndex()
  let partialPath = ExtractPath()
  call system('firefox ' . g:noteurl . partialPath)
endfunction


command! GoToIndex :execute 'edit' g:notesdir . 'index.md'
command! -nargs=* GrepPicoNotes :call GrepNotes(<f-args>)
command! -bang -nargs=* GrepNotesFzf
  \ call fzf#vim#grep(
  \   'rg --type md --column --line-number --no-heading --color=always --smart-case -- '.shellescape(<q-args>), 1,
  \   fzf#vim#with_preview({'dir': g:notesdir}), <bang>0)

nnoremap <silent> <Leader>ww :GoToIndex<CR>
nnoremap <silent> <Leader>wi :call GoToNoteWebPage()<CR>
nnoremap <silent> <Leader>wf :call GoToNoteFile('edit')<CR>
nnoremap <silent> <Leader>wt :call GoToNoteFile('tabe')<CR>
nnoremap <silent> <Leader>wv :call GoToNoteFile('vs')<CR>
nnoremap <silent> <Leader>wx :call GoToNoteFile('sp')<CR>
nnoremap <silent> <Leader>wd :call DeleteNoteFile()<CR>
nnoremap <silent> <Leader>wg :GrepNotesFzf<CR>
