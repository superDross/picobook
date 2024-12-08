" Browser.vim
"
" Functions associated with opening files in the browser


function! picobook#browser#GetBrowserSubCommand() abort
  let browser = get(g:, 'browser', 'firefox')
  if has('mac')
    let title_case_browser = toupper(browser[0]) . browser[1:]
    return 'open -a /Applications/' . title_case_browser . '.app'
  endif
  return browser
endfunction


function! picobook#browser#OpenPageInGitHub() abort
  call picobook#exceptions#RaiseErrorIfNotInIndex()
  let partialPath = picobook#parsing#ExtractPath()
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


function! picobook#browser#OpenPageInBrowser() abort
  call picobook#exceptions#RaiseErrorIfNotInIndex()
  let filepath = picobook#parsing#ExtractFullPath()
  call system(g:browser . ' ' . filepath)
endfunction


function! picobook#browser#OpenFileInBrowser() abort
  let indexpath = expand('%:p')
  call system(g:browser . ' ' . indexpath)
endfunction
