function CreateParentDir(filepath)
  let dirpath = fnamemodify(a:filepath, ':h')
  if !filereadable(dirpath)
    call system('mkdir ' . dirpath)
  endif
endfunction


function CheckIfInIndex()
  try
    if expand('%:h')[-9:-1] !=# '/_indexes'
      throw 'Command invalid outside index page'
    endif
  catch /.invalid outside index/
    echoerr 'Command only valid within picobook index files'
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
    execute 'delete'
    silent! write
  endif
endfunction


function MoveNoteFile()

  " only allow function if executed within an index file
  call CheckIfInIndex()

  " get path for current file under cursor
  let filepath = GetNoteFileName()
  let relativepath = ExtractPath()
  let filename = fnamemodify( filepath, ':p:t')

  " append forward slash if not present on new directory
  let newdir = input('Enter new directory: ')
  if newdir[-1:] !=# '/'
    let newdir = newdir . '/'
  endif

  " get the path for the new files
  let new_relativepath = newdir . filename
  let new_filename = g:notesdir . new_relativepath

  let confirmation = input(
  \  'Move file from ' . relativepath .
  \  ' to ' . new_relativepath . '? (y/n): '
  \)

  if confirmation ==# 'y'
    " s/currentname/newname/
    let new_line = substitute(
    \  getline('.'),
    \  relativepath,
    \  new_relativepath,
    \  ''
    \)
    call system('mkdir -p ' . fnamemodify(new_filename, ':p:h'))
    call system('mv ' . filepath . ' ' . new_filename)
    " setline with new substitute line
    call setline(line('.'), new_line)
  endif

endfunction


function GoToNoteFile(opencommand)
  call CheckIfInIndex()
  let note_file = GetNoteFileName()
  call CreateParentDir(note_file)
  silent! write
  execute a:opencommand . note_file
endfunction


function GoToNoteWebPage()
  call CheckIfInIndex()
  let partialPath = ExtractPath()
  call system(g:browser . ' ' . g:noteurl . partialPath)
endfunction


function GoToIndex()
  let indexpath = g:notesdir . '/_indexes/' . 'index.md'
  call CreateParentDir(indexpath)
  execute 'edit ' . indexpath
endfunction


let g:browser = get(g:, 'browser', 'firefox')

command! GoToIndex :call GoToIndex()
command! -bang -nargs=* GrepPicoNotes :call picobook#fzf#FzfNotes(<q-args>)
nnoremap <silent> <Leader>ww :call GoToIndex()<CR>
nnoremap <silent> <Leader>wi :call GoToNoteWebPage()<CR>
nnoremap <silent> <Leader>wf :call GoToNoteFile('edit')<CR>
nnoremap <silent> <Leader>wt :call GoToNoteFile('tabe')<CR>
nnoremap <silent> <Leader>wv :call GoToNoteFile('vs')<CR>
nnoremap <silent> <Leader>wx :call GoToNoteFile('sp')<CR>
nnoremap <silent> <Leader>wd :call DeleteNoteFile()<CR>
nnoremap <silent> <Leader>wm :call MoveNoteFile()<CR>
nnoremap <silent> <Leader>wg :GrepPicoNotes<CR>
