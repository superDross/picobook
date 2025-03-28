" Creation.vim
"
" Note file and directory creation


function! s:CreateNewFile(filetitle = v:null, ext = v:null) abort
  " create a new index entry and go to the new page
  call picobook#exceptions#RaiseErrorIfNotInIndex()
  let ext = a:ext

  " check if no title is given, then error if it is
  let filetype = (ext ==# '.md') ? 'page' : 'script'
  let filetitle = (a:filetitle is v:null) ? input('Enter title of new ' . filetype . ': ') : a:filetitle
  call picobook#exceptions#NoInputGiven(filetitle)

  " ask for filetype if not given
  if ext is v:null
    let ext = input('Enter extension of new script (e.g. .py, .vim): ')
    call picobook#exceptions#NoInputGiven(ext)
    let ext = (ext[0] ==# '.') ? ext : '.' . ext
  endif

  " check if file already exists, then error if it does
  try
    let relpath = s:CreateFilePath(filetitle, ext)
    if filereadable(picobook#parsing#ExtractFullPath(relpath))
      throw 'File already exists'
    endif
  catch
    echoerr 'Caught Exception: ' . v:exception
  endtry

  " write the new filename to the page and go to it
  call append(line('.'), '- [' . filetitle . '](' . relpath . ')')
  normal! j
  call picobook#navigation#GoToNoteFile('edit', filetitle)
  silent! write
endfunction


function! s:CreateFilePath(filetitle, ext = '.md') abort
  " creates a relative file path with the file title and subtitle
  let newfile = tolower(join(split(a:filetitle, ' '), '_')) . a:ext
  if picobook#utils#InIndex()
    return newfile
  endif
  let subtitle = picobook#parsing#GetSubtitle()
  let dirname = fnamemodify(expand('%:p'), ':t:r')
  let dirname = (subtitle ==# '') ? dirname : dirname . '/' . subtitle
  return '../' . dirname . '/' . newfile
endfunction


function! picobook#creation#CreateParentDir(filepath) abort
  " create the directories for the file if they do not exist
  try
    let dirpath = expand(fnamemodify(a:filepath, ':h'))
    if stridx(dirpath, expand(g:notesdir)) == -1
      throw 'Directories and files can only be created within the notes directory: ' . g:notesdir
    endif
  catch
    echoerr 'Caught error: ' . v:exception
  endtry

  if !filereadable(dirpath)
    call mkdir(dirpath, 'p')
  endif
endfunction


function! picobook#creation#AddPageHeader(back_filepath, title = v:null) abort
  " ensures a back button, table of contents and title are present at the top
  " of the file
  if expand('%:e') !=# 'md' || getline(1) =~# 'GITCRYPT'
    return
  endif

  " back_marker is used to check if back button already exists
  if search('\<back-button-picobook\>', 'nw') == 1 && &filetype ==# 'markdown'
    return
  endif
  " create all the necessary text to be inserted
  let back_marker = '<!-- back-button-picobook -->'
  let back_button = '[Back](' . a:back_filepath . ')'
  let toc = '[TOC]'
" if not present, add back button to top of file & save
  normal! ggO
  call append(line('.') - 1, back_marker)
  call append(line('.') - 1, back_button)
  call append(line('.'), toc)
  if a:title != v:null
    call append(line('.') + 2, '# ' . a:title)
  endif
  silent! write
endfunction


function! picobook#creation#CreateNewScript(filetitle = v:null, ext = v:null) abort
  let ext = a:ext
  if ext isnot v:null
    let ext = (ext[0] ==# '.') ? ext : '.' . ext
  endif
  call s:CreateNewFile(a:filetitle, ext)
endfunction


function! picobook#creation#CreateNewPage(filetitle = v:null) abort
  call s:CreateNewFile(a:filetitle, '.md')
endfunction
