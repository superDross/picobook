function! GrepNotes(query)
  execute 'vimgrep! /\c' . a:query . '/j ' . g:notesdir . '**/*.md'
endfunction


nnoremap <silent> <Leader>ww :execute 'edit' g:notesdir . 'index.md'<CR>
nnoremap <silent> <Leader>wf :execute 'edit' g:notesdir . expand('<cfile>')<CR>
nnoremap <silent> <Leader>wt :execute 'tabe' g:notesdir . expand('<cfile>')<CR>
nnoremap <silent> <Leader>wv :execute 'vs' g:notesdir . expand('<cfile>')<CR>
nnoremap <silent> <Leader>wx :execute 'sp' g:notesdir . expand('<cfile>')<CR>

command! -nargs=1 GrepPicoNotes :call GrepNotes(<f-args>)
