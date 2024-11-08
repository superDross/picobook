function CreateParentDir(filepath)
  let dirpath = fnamemodify(a:filepath, ':h')
  if !filereadable(dirpath)
    call system('mkdir ' . dirpath)
  endif
endfunction


function CheckIfInIndex()
  try
    if stridx(expand('%h'), '_indexes/') == -1
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
    echoerr 'This line does not contain a valid link; must start with "-" and contain brackets "()"'
  endtry
endfunction


function GetNoteFileName()
  let partialPath = ExtractPath()

  " make sure partialPath starts with '../'
  " ignore that does not contain / as they are index files
  if partialPath[:2] !=# '../' && partialPath =~# '/'
    normal! 0f(a../
    let partialPath = '../' . partialPath
  endif

  " e.g. /home/demon/notes/_indexes/languages.md
  return expand(g:notesdir . '/_indexes/' . partialPath)
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


function AddBackButton(back_filepath)
  " back_marker is used to check if back button already exists
  let back_marker = '<!-- back-button-picobook -->'
  let back_button = '[Back](' . a:back_filepath . ')'
  let toc = '[TOC]'
  " if not present, add back button to top of file & save
  if search('\<back-button-picobook\>', 'nw') == 0 && &filetype ==# 'markdown'
    normal! ggO
    call append(line('.') - 1, back_marker)
    call append(line('.') - 1, back_button)
    call append(line('.'), toc)
    silent! write
  endif
endfunction


function GoToNoteFile(opencommand)
  call CheckIfInIndex()
  let note_file = GetNoteFileName()
  call CreateParentDir(note_file)
  silent! write
  let current_index_path = expand('%:p')
  execute a:opencommand . note_file
  let back_file_path = picobook#utils#GetRelativePath(current_index_path, expand('%:p'))
  call AddBackButton(back_file_path)
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
  let filepath = GetNoteFileName()
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


function CreateNewPage()
  " create a new index entry and go to the new page
  call CheckIfInIndex()
  let newdir = input('Enter title of new page: ')

  " check if newdir is empty, then error if it is
  if newdir ==# ''
    echoerr 'No title entered'
    return
  endif

  " get the base file name and remove the extension
  let dirname = fnamemodify(expand('%:p'), ':t:r')
  let newfile = tolower(join(split(newdir, ' '), '_')) . '.md'
  let fullpath = (dirname ==# 'index') ? newfile : '../' . dirname . '/' . newfile

  " check if file already exists, then error if it does
  if filereadable(fullpath)
    echoerr 'File already exists'
    return
  endif

  " write the new filename to the page and go to it
  call append(line('.'), '- [' . newdir . '](' . fullpath . ')')
  normal! j
  call GoToNoteFile('edit')
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
