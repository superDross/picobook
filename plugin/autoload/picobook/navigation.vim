" Navigation.vim
"
" Facilitates navigation between notes and indexes


function! picobook#navigation#GoToIndex() abort
  let indexpath = g:notesdir . '/_indexes/' . 'index.md'
  call picobook#creation#CreateParentDir(indexpath)
  execute 'edit ' . indexpath
  if filereadable(expand(indexpath)) ==# 0
    call append(0, ['# Piconotes', '', '[TOC]', '', '## Indexes', ''])
  endif
  silent! write
endfunction


function! picobook#navigation#GoToNoteFile(opencommand, title = v:null) abort
  " open and/or create the note file under the cursor and create a back button, if not
  " already present
  call picobook#exceptions#RaiseErrorIfNotInIndex()
  let note_file = picobook#parsing#ExtractFullPath()
  call picobook#creation#CreateParentDir(note_file)
  silent! write
  let current_index_path = expand('%:p')
  execute a:opencommand . note_file
  let back_file_path = picobook#utils#GetRelativePath(current_index_path, expand('%:p'))
  call picobook#creation#AddPageHeader(back_file_path, a:title)
endfunction
