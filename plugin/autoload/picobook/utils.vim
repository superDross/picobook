" Utils.vim
"
" Various utility functions used throughout the project


function! picobook#utils#IsInstalled(package) abort
  " check if the given package is installed or not
  let loaded_packages = filter(
    \ split(execute(':scriptname'), "\n"),
    \   'v:val =~? "' . a:package . '"'
    \ )
  if loaded_packages !=# []
    return 1
  endif
  return 0
endfunction


function! picobook#utils#CharUnderCursor() abort
  " return the character under the cursor
  return strcharpart(getline('.')[col('.') - 1:], 0, 1)
endfunction


function! picobook#utils#GetRelativePath(to, from) abort
  " get the relative path from one file to another
  let to = fnamemodify(a:to, ':p')
  let from = fnamemodify(a:from, ':p')

  " identify the common path between the two args
  let common_path = ''
  let i = 0
  for name in split(to, '/')
    if name == split(from, '/')[i]
      let common_path = common_path . '/' . name
      let i += 1
    else
       let common_path = common_path . '/'
      break
    endif
  endfor

  " get the number of directories to go up
  let _from = substitute(from, common_path, '', '')
  let _from = substitute(_from, fnamemodify(from, ':t'), '', '')
  let relative_len = len(split(_from, '/'))

  " build the relative path
  let relative_up = ''
  for i in range(0, relative_len - 1)
    let relative_up = relative_up . '../'
  endfor
  let relative_up = (empty(relative_up) ? './' : relative_up)
  let relative_path = relative_up . substitute(to, common_path, '', '')
  " stops multiple forward slashes e.g. ..//_index/index.md
  let normalised_relative_path = substitute(relative_path, '//', '/', 'g')
  return normalised_relative_path
endfunction


function! picobook#utils#InIndex() abort
  " NOTE: there should not be // in the path, investigate why they appear
  let here = substitute(expand('%:p'), '//', '/', 'g')
  let index = substitute(expand(g:notesdir) . '_indexes/index.md', '//', '/', 'g')
  return (here ==# index) ? 1 : 0
endfunction


