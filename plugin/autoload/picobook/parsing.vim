function! picobook#parsing#ExtractPath(text = getline('.')) abort
  " extracts path link under cursor as is (relative path)
  try
    " if startswith '-' and has brackets
    if a:text =~# '^-' && a:text =~# '(' && a:text =~# ')'
      return matchstr(a:text, '(\zs.\{-}\ze)')
    else
      throw 'No path found on the current line'
    endif
  catch 
    echoerr 'Caught error: ' . v:exception
  endtry
endfunction


function! picobook#parsing#ExtractFullPath(partialPath = '') abort
  " gets the relative path under the cursor (or parsed) and returns the full path

  " make sure partialPath starts with '../'
  " ignore that does not contain / as they are index files
  let partialPath = (a:partialPath ==# '') ? picobook#parsing#ExtractPath() : a:partialPath
  if partialPath[:2] !=# '../' && partialPath =~# '/'
    normal! 0f(a../
    let partialPath = '../' . partialPath
  endif

  " e.g. /home/demon/notes/_indexes/languages.md
  return expand(g:notesdir . '/_indexes/' . partialPath)
endfunction


function! picobook#parsing#GetSubtitle() abort
  " gets the text of the title at the ## level and returns it, if it exists
  let pos = getpos('.')
  let match_post = search('^## [A-Za-z].*', 'bW')
  let subtitle = ''
  if match_post > 0
    execute match_post | norm! 0W"zy$
    let subtitle = substitute(tolower(getreg('z')), ' ', '_', 'g')
  endif
  call setpos('.', pos)
  return subtitle
endfunction
