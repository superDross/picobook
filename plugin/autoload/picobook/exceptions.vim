" Exceptions.vim
"
" Functions associated with error handling and exceptions


function! picobook#exceptions#RaiseErrorIfNotInIndex() abort
  try
    if stridx(expand('%:p:h'), '/_indexes') == -1
      throw 'Command only valid within picobook index files'
    endif
  catch
    echoerr 'Caught error: ' . v:exception
  endtry
endfunction


function! picobook#exceptions#RaiseIfNoInputGiven(value) abort
  try
    if a:value is '' || a:value is v:null
      throw 'No input given'
    endif
  catch
    echoerr 'Caught Exception: ' . v:exception
  endtry
endfunction


function! picobook#exceptions#RaiseIfFileExists(filepath, relative = 0) abort
  let filepath = (a:relative) ? picobook#parsing#ExtractFullPath(a:filepath) : a:filepath
  try
    if filereadable(filepath)
      throw 'File already exists'
    endif
  catch
    echoerr 'Caught Exception: ' . v:exception
  endtry
endfunction


function! picobook#exceptions#RaiseIfDirCreatedOutsideNotesDir(dirpath) abort
  try
    if stridx(a:dirpath, expand(g:notesdir)) == -1
      throw 'Directories and files can only be created within the notes directory: ' . g:notesdir
    endif
  catch
    echoerr 'Caught Exception: ' . v:exception
  endtry
endfunction
