" FZF.vim
"
" Fzf integration with note files


function! s:FzfLuaNotes(args) abort
  " interactiely search notes contents using fzf-lua
  if picobook#utils#IsInstalled('fzf-lua')
    lua require('fzf-lua').live_grep_native({
      \ prompt = 'PicoNotes> ',
      \ previewer='bat',
      \ rg_glob=true,
      \ cwd = vim.g.notesdir,
      \ rg_opts = '--type md --column --line-number --no-heading --color=always --smart-case --',
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
  if g:notesdir ==# '' || !isdirectory(expand(g:notesdir))
    echoerr 'g:notesdir is not set or is not a directory'
    return
  endif
  if has('nvim') && picobook#utils#IsInstalled('fzf-lua')
    return s:FzfLuaNotes(a:args)
  endif
  return s:FzfVimNotes(a:args)
endfunction
