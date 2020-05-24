# <sub>pico</sub>Book

A very tiny & simple notebook/wiki for vim.

Heavily inspired by [vimwiki](https://github.com/vimwiki/vimwiki).

## Key Bindings

Normal Mode:

- `<Leader>ww` -- Open index page
- `<Leader>wf` -- Open wiki link
- `<Leader>wt` -- Open wiki link in new tab
- `<Leader>wv` -- Open wiki link in new vsplit
- `<Leader>wx` -- Open wiki link in new hsplit
- `<Leader>wg` -- FZF grep notes (requires [FZF](https://github.com/junegunn/fzf.vim))

Commands:

- `:GoToIndex` -- Open index page
- `:GrepNotes *` -- Vimgrep given args
- `:GrepNotesFzf` -- FZF grep notes

## Setup

Install:

```vimscript
Plug 'superdross/picobook'
```

Set the directory to hold all the notes.

```vimscript
g:notesdir = '/som/dir/path/'
```
