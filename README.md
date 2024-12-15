# <sub>pico</sub>B<sub>ook</sub>

A very tiny & simple notebook for vim.

Heavily inspired by [vimwiki](https://github.com/vimwiki/vimwiki).

Compatible with Vim8.1+

## Key Bindings

Normal Mode:

- `<Leader>ww` -- Open index page
- `<Leader>wo` -- Open index page in your browser (browser specified with `g:browser`)
- `<Leader>wf` -- Open wiki link
- `<Leader>wt` -- Open wiki link in new tab
- `<Leader>wv` -- Open wiki link in new vsplit
- `<Leader>wx` -- Open wiki link in new hsplit
- `<Leader>wi` -- Open wiki link in GitHub
- `<Leader>wb` -- Open wiki link in browser
- `<Leader>wd` -- Delete wiki link and associated file
- `<Leader>wm` -- Move wiki link and associated file
- `<Leader>wg` -- FZF grep notes (requires [FZF](https://github.com/junegunn/fzf.vim))
- `<Leader>wp` -- Create new wiki link and go to the file
- `<Leader>ws` -- Create new wiki link and go to the script

Commands:

- `:GoToIndex` -- Open index page
- `:GoToNoteWebPage` -- Open wiki link in GitHub
- `:GrepPicoNotes *` -- Vimgrep given args
- `:GrepPicoNotesFzf` -- FZF grep notes

## Setup

### Install:

```vimscript
Plug 'superdross/picobook'
```

### Settings

Set the directory to hold all the notes.

```vimscript
let g:notesdir = '/som/dir/path/'
" path to open weblinks
let g:noteurl = 'https://github.com/superDross/dotfiles/blob/master/notes/'
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

<!-- creates a sub-index file specifically for languages -->
- [Languages](languages.md)

## Data Structures

- [Linked Lists](data_structures/linkedlist.md)
- [Graph Data](data_structures/graphdata.md)

## Python

- [Async](python/async_module.py)
- [Cython](python/cython_tutorial.pyx)
```

Place the cursor at the `Linked Lists` line and press `<Leader>wf`, the file `/home/me/notes/data_structrues/linkedlist.md` will be opened in the current window.
