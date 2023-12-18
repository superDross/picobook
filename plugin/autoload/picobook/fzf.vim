" fzf.vim
"
" Fzf integration with note files


function! s:FzfLuaNotes(args) abort
  " interactiely search notes contents using fzf-lua
  if picobook#utils#IsInstalled('fzf-lua')
    lua require('fzf-lua').grep({
      \ rg_glob=true,
      \ cwd = vim.g.notesdir,
      \ search=vim.fn.eval('a:args') .. ' -- *.md',
      \ no_esc=true
    \ })
    return
  else
    echoerr 'ibhagwan/fzf-lua is not loaded or installed'
  endif
endfunction


function! s:FzfVimNotes(args) abort
  " interactiely search notes contents using fzf.vim
  if picobook#utils#IsInstalled('fzf.vim')
    call fzf#vim#grep(
    \   'rg --type md --column --line-number --no-heading --color=always --smart-case -- '.shellescape(a:args), 1,
    \   fzf#vim#with_preview({'dir': g:notesdir}))
  else
    echoerr 'junegunn/fzf.vim is not loaded or installed'
  endif
endfunction


function! picobook#fzf#FzfNotes(args) abort
  " interactively search notes contents using junegunn/fzf.vim or fzf-lua
  if has('nvim') && picobook#utils#IsInstalled('fzf-lua')
    return s:FzfLuaNotes(a:args)
  endif
  return s:FzfVimNotes(a:args)
endfunction
