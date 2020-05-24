# <sub>pico</sub>Book

A very tiny & simple notebook for vim.

Heavily inspired by [vimwiki](https://github.com/vimwiki/vimwiki).

## Key Bindings

Normal Mode:

- `<Leader>ww` -- Open index page
- `<Leader>wf` -- Open wiki link
- `<Leader>wt` -- Open wiki link in new tab
- `<Leader>wv` -- Open wiki link in new vsplit
- `<Leader>wx` -- Open wiki link in new hsplit
- `<Leader>wd` -- Delete wiki link
- `<Leader>wg` -- FZF grep notes (requires [FZF](https://github.com/junegunn/fzf.vim))

Commands:

- `:GoToIndex` -- Open index page
- `:GrepNotes *` -- Vimgrep given args
- `:GrepNotesFzf` -- FZF grep notes

## Setup

### Install:

```vimscript
Plug 'superdross/picobook'
```

### Settings

Set the directory to hold all the notes.

```vimscript
g:notesdir = '/som/dir/path/'
```

## Example Usage

Set notes location and go to the wiki page:

```vimscript
:let g:notesdir = '/home/me/notes/'
:GoToIndex
```

Create a basic Markdown index file:

```md
# Index

## Data Structures

- [Linked Lists](data_structures/linkedlist.md)
- [Graph Data](data_structures/graphdata.md)

## Python

- [Async](python/async_module.py)
- [Cython](python/cython_tutorial.pyx)
```

Place the cursor at the `Linked Lists` line and press `<Leader>wf`, the file `/home/me/notes/data_structrues/linkedlist.md` will be opened in the current window.
