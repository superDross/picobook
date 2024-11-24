function CreateParentDir(filepath)
  " create the directories for the file if they do not exist
  let dirpath = expand(fnamemodify(a:filepath, ':h'))
  if !filereadable(dirpath)
    call mkdir(dirpath, 'p')
  endif
endfunction


function CheckIfInIndex()
  try
    if stridx(expand('%:p:h'), '/_indexes') == -1
      throw 'Command invalid outside index page'
    endif
  catch /.invalid outside index/
    echoerr 'Command only valid within picobook index files'
  endtry
endfunction


function ExtractPath(text = getline('.'))
  " extracts path link under cursor as is (relative path)
  try
    " if startswith '-' and has brackets
    if a:text =~# '^-' && a:text =~# '(' && a:text =~# ')'
      return matchstr(a:text, '(\zs.\{-}\ze)')
    else
      throw 'not valid line'
    endif
  catch /not valid line/
    echoerr 'This line does not contain a valid link; must start with "-" and contain brackets "()"'
  endtry
endfunction


function ExtractFullPath(partialPath = ExtractPath())
  " gets the relative path under the cursor (or parsed) and returns the full path

  " make sure partialPath starts with '../'
  " ignore that does not contain / as they are index files
  if a:partialPath[:2] !=# '../' && a:partialPath =~# '/'
    normal! 0f(a../
    let a:partialPath = '../' . a:partialPath
  endif

  " e.g. /home/demon/notes/_indexes/languages.md
  return expand(g:notesdir . '/_indexes/' . a:partialPath)
endfunction


function DeleteNoteFile()
  call CheckIfInIndex()
  let note_file = ExtractFullPath()
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
  let filepath = ExtractFullPath()
  let relativepath = ExtractPath()
  let filename = fnamemodify( filepath, ':p:t')

  " append forward slash if not present on new directory
  let newdir = input('Enter new directory (relative to the top level dir): ')
  if newdir[-1:] !=# '/'
    let newdir = newdir . '/'
  endif

  " get the path for the new files
  let new_relativepath = newdir . filename
  let new_filename = g:notesdir . new_relativepath

  " e.g. ~/bin/piconotes/ -> piconotes/
  let rootdir =  fnamemodify(substitute(expand(g:notesdir), '/$', '', ''), ':t') . '/'
  let confirmation = input(
  \  'Move file from ' . relativepath .
  \  ' to ' . rootdir . new_relativepath . '? (y/n): '
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


function AddPageHeader(back_filepath, title = v:null)
  " ensures a back button, table of contents and title are present at the top
  " of the file

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


function GoToNoteFile(opencommand, title = v:null)
  " open and/or create the note file under the cursor and create a back button, if not
  " already present
  call CheckIfInIndex()
  let note_file = ExtractFullPath()
  call CreateParentDir(note_file)
  silent! write
  let current_index_path = expand('%:p')
  execute a:opencommand . note_file
  let back_file_path = picobook#utils#GetRelativePath(current_index_path, expand('%:p'))
  call AddPageHeader(back_file_path, a:title)
endfunction


function OpenPageInGitHub()
  call CheckIfInIndex()
  let partialPath = ExtractPath()
  " is index file
  if partialPath !~# '/'
    let partialPath = '_indexes/' . partialPath
  " is note file
  elseif partialPath[:2] ==# '../'
    let partialPath = partialPath[2:]
  endif
  echo g:browser . ' ' . g:noteurl . partialPath
  call system(g:browser . ' ' . g:noteurl . partialPath)
endfunction


function OpenPageInBrowser()
  call CheckIfInIndex()
  let filepath = ExtractFullPath()
  call system(g:browser . ' ' . filepath)
endfunction


function OpenFileInBrowser()
  let indexpath = expand('%:p')
  call system(g:browser . ' ' . indexpath)
endfunction


function GoToIndex()
  let indexpath = g:notesdir . '/_indexes/' . 'index.md'
  call CreateParentDir(indexpath)
  execute 'edit ' . indexpath
endfunction


function GetBrowserSubCommand()
  let browser = get(g:, 'browser', 'firefox')
  if has('mac')
    let title_case_browser = toupper(browser[0]) . browser[1:]
    return 'open -a /Applications/' . title_case_browser . '.app'
  endif
  return browser
endfunction


function GetSubtitle()
  " gets the text of the title at the ## level and returns it, if it exists
  let pos = getpos('.')
  let match_post = search('^## [A-Za-z].*', 'bW')
  let subtitle = ''
  if match_post > 0
    execute match_post | norm 0W"zy$
    let subtitle = substitute(tolower(getreg('z')), ' ', '_', 'g')
  endif
  call setpos('.', pos)
  return subtitle
endfunction


function CreateFilePath(filetitle)
  " creates a relative file path with the file title and subtitle
  let subtitle = GetSubtitle()
  let dirname = fnamemodify(expand('%:p'), ':t:r')
  let dirname = (subtitle ==# '') ? dirname : dirname . '/' . subtitle
  let newfile = tolower(join(split(a:filetitle, ' '), '_')) . '.md'
  return (dirname ==# 'index') ? newfile : '../' . dirname . '/' . newfile
endfunction


function CreateNewPage()
  " create a new index entry and go to the new page
  call CheckIfInIndex()
  let filetitle = input('Enter title of new page: ')

  " check if no title is given, then error if it is
  if filetitle ==# ''
    echoerr 'No title entered'
    return
  endif

  " check if file already exists, then error if it does
  let relpath = CreateFilePath(filetitle)
  if filereadable(ExtractFullPath(relpath))
    echoerr 'File already exists'
    return
  endif

  " write the new filename to the page and go to it
  call append(line('.'), '- [' . filetitle . '](' . relpath . ')')
  normal! j
  call GoToNoteFile('edit', filetitle)
endfunction


let g:browser = GetBrowserSubCommand()

command! GoToIndex :call GoToIndex()
command! -bang -nargs=* GrepPicoNotes :call picobook#fzf#FzfNotes(<q-args>)
nnoremap <silent> <Leader>ww :call GoToIndex()<CR>
nnoremap <silent> <Leader>wo :call OpenFileInBrowser()<CR>
nnoremap <silent> <Leader>wi :call OpenPageInGitHub()<CR>
nnoremap <silent> <Leader>wb :call OpenPageInBrowser()<CR>
nnoremap <silent> <Leader>wf :call GoToNoteFile('edit')<CR>
nnoremap <silent> <Leader>wt :call GoToNoteFile('tabe')<CR>
nnoremap <silent> <Leader>wv :call GoToNoteFile('vs')<CR>
nnoremap <silent> <Leader>wx :call GoToNoteFile('sp')<CR>
nnoremap <silent> <Leader>wd :call DeleteNoteFile()<CR>
nnoremap <silent> <Leader>wm :call MoveNoteFile()<CR>
nnoremap <silent> <Leader>wg :GrepPicoNotes<CR>
nnoremap <silent> <Leader>wp :call CreateNewPage()<CR>
