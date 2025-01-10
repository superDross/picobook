" picobook.vim - Wiki Plugin
" Author:      David Ross <https://github.com/superDross/>


" prevents loading the plugin multiple times
if exists('g:loaded_picobook')
  finish
endif
let g:loaded_picobook = 1


" check if g:notesdir is set, warn and finish if not
if !exists('g:notesdir')
  echohl WarningMsg
  echomsg '[WARNING] g:notesdir not set, set it to the directory containing your notes'
  echohl None
  finish
endif


" ensure g:notesdir is set as expected
let g:notesdir = (g:notesdir[-1] ==# '/') ? expand(g:notesdir) : expand(g:notesdir . '/')
let g:browser = picobook#browser#GetBrowserSubCommand()


command! GoToIndex :call picobook#navigation#GoToIndex()
command! -bang -nargs=* GrepPicoNotes :call picobook#fzf#FzfNotes(<q-args>)
nnoremap <silent> <Leader>ww :call picobook#navigation#GoToIndex()<CR>
nnoremap <silent> <Leader>wo :call picobook#browser#OpenFileInBrowser()<CR>
nnoremap <silent> <Leader>wi :call picobook#browser#OpenPageInGitHub()<CR>
nnoremap <silent> <Leader>wb :call picobook#browser#OpenPageUnderCursorInBrowser()<CR>
nnoremap <silent> <Leader>wf :call picobook#navigation#GoToNoteFile('edit')<CR>
nnoremap <silent> <Leader>wt :call picobook#navigation#GoToNoteFile('tabe')<CR>
nnoremap <silent> <Leader>wv :call picobook#navigation#GoToNoteFile('vs')<CR>
nnoremap <silent> <Leader>wx :call picobook#navigation#GoToNoteFile('sp')<CR>
nnoremap <silent> <Leader>wd :call picobook#movedelete#DeleteNoteFile()<CR>
nnoremap <silent> <Leader>wm :call picobook#movedelete#MoveNoteFile()<CR>
nnoremap <silent> <Leader>wg :GrepPicoNotes<CR>
nnoremap <silent> <Leader>wp :call picobook#creation#CreateNewPage()<CR>
nnoremap <silent> <Leader>ws :call picobook#creation#CreateNewScript()<CR>
