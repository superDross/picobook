" MoveDelete.vim
"
" Allows for moving and deleting note files from within the index file


function! picobook#movedelete#DeleteNoteFile(confirmation = 1) abort
  " delete the piconote file under the cursor and its corresponding line in the index file
  call picobook#exceptions#RaiseErrorIfNotInIndex()
  let note_file = picobook#parsing#ExtractFullPath()
  let answer = (a:confirmation == 1) ? input('Delete file? (y/n): ') : 'y'
  if answer ==# 'y'
    call delete(note_file)
    execute 'delete'
    silent! write
  endif
endfunction


function! picobook#movedelete#MoveNoteFile(newdir = v:null, confirmation = 1) abort
  " move the piconote file under the cursor to a new directory and update the
  " index file

  " only allow function if executed within an index file
  call picobook#exceptions#RaiseErrorIfNotInIndex()

  " get path for current file under cursor
  let filepath = picobook#parsing#ExtractFullPath()
  let relativepath = picobook#parsing#ExtractPath()
  let filename = fnamemodify( filepath, ':p:t')

  " append forward slash if not present on new directory
  let q = 'Enter new directory (relative to the top level dir): '
  let newdir = (a:newdir == v:null) ? input(q) : a:newdir
  if newdir[-1:] !=# '/'
    let newdir = newdir . '/'
  endif

  " get the path for the new files
  let new_relativepath = newdir . filename
  let new_filename = g:notesdir . new_relativepath

  " e.g. ~/bin/piconotes/ -> piconotes/
  let rootdir =  fnamemodify(substitute(expand(g:notesdir), '/$', '', ''), ':t') . '/'
  if a:confirmation ==# 1
    let confirmation = input(
    \  'Move file from ' . relativepath .
    \  ' to ' . rootdir . new_relativepath . '? (y/n): '
    \)
  else
    let confirmation = 'y'
  endif

  if confirmation ==# 'y'
    " s/currentname/newname/
    let new_line = substitute(
    \  getline('.'),
    \  relativepath,
    \  '../' . new_relativepath,
    \  ''
    \)
    call system('mkdir -p ' . fnamemodify(new_filename, ':p:h'))
    call system('mv ' . filepath . ' ' . new_filename)
    " setline with new substitute line
    call setline(line('.'), new_line)
    silent! write
  endif
endfunction

