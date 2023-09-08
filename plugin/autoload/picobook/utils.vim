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
