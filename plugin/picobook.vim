function ExtractPath(text = getline('.'))
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


function ExtractFullPath(partialPath = '')
  " gets the relative path under the cursor (or parsed) and returns the full path

  " make sure partialPath starts with '../'
  " ignore that does not contain / as they are index files
  let partialPath = (a:partialPath ==# '') ? ExtractPath() : a:partialPath
  if partialPath[:2] !=# '../' && partialPath =~# '/'
    normal! 0f(a../
    let partialPath = '../' . partialPath
  endif

  " e.g. /home/demon/notes/_indexes/languages.md
  return expand(g:notesdir . '/_indexes/' . partialPath)
endfunction




function GoToNoteFile(opencommand, title = v:null)
  " open and/or create the note file under the cursor and create a back button, if not
  " already present
  call picobook#exceptions#RaiseErrorIfNotInIndex()
  let note_file = ExtractFullPath()
  call picobook#creation#CreateParentDir(note_file)
  silent! write
  let current_index_path = expand('%:p')
  execute a:opencommand . note_file
  let back_file_path = picobook#utils#GetRelativePath(current_index_path, expand('%:p'))
  call picobook#creation#AddPageHeader(back_file_path, a:title)
endfunction


function GoToIndex()
  let indexpath = g:notesdir . '/_indexes/' . 'index.md'
  call picobook#creation#CreateParentDir(indexpath)
  execute 'edit ' . indexpath
  if filereadable(expand(indexpath)) ==# 0
    call append(0, ['# Piconotes', '', '[TOC]', '', '## Indexes', ''])
  endif
  write
endfunction


function GetSubtitle()
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

function InIndex()
  " NOTE: there should not be // in the path, investigate why they appear
  let here = substitute(expand('%:p'), '//', '/', 'g')
  let index = substitute(expand(g:notesdir) . '_indexes/index.md', '//', '/', 'g')
  return (here ==# index) ? 1 : 0
endfunction



if !exists('g:notesdir')
  echohl WarningMsg
  echomsg '[WARNING] g:notesdir not set, set it to the directory containing your notes'
  echohl None
  finish
endif

" ensure g:notesdir is set as expected
let g:notesdir = (g:notesdir[-1] ==# '/') ? expand(g:notesdir) : expand(g:notesdir . '/')
let g:browser = picobook#external#GetBrowserSubCommand()


command! GoToIndex :call GoToIndex()
command! -bang -nargs=* GrepPicoNotes :call picobook#fzf#FzfNotes(<q-args>)
nnoremap <silent> <Leader>ww :call GoToIndex()<CR>
nnoremap <silent> <Leader>wo :call picobook#external#OpenFileInBrowser()<CR>
nnoremap <silent> <Leader>wi :call picobook#external#OpenPageInGitHub()<CR>
nnoremap <silent> <Leader>wb :call picobook#external#OpenPageInBrowser()<CR>
nnoremap <silent> <Leader>wf :call GoToNoteFile('edit')<CR>
nnoremap <silent> <Leader>wt :call GoToNoteFile('tabe')<CR>
nnoremap <silent> <Leader>wv :call GoToNoteFile('vs')<CR>
nnoremap <silent> <Leader>wx :call GoToNoteFile('sp')<CR>
nnoremap <silent> <Leader>wd :call picobook#movedelete#DeleteNoteFile()<CR>
nnoremap <silent> <Leader>wm :call picobook#movedelete#MoveNoteFile()<CR>
nnoremap <silent> <Leader>wg :GrepPicoNotes<CR>
nnoremap <silent> <Leader>wp :call picobook#creation#CreateNewPage()<CR>
