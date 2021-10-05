syntax on

set number relativenumber

function! GitBranch()
return system("git rev-parse --abbrev-ref HEAD 2>/dev/null | tr -d '\n'")
endfunction

function! StatuslineGit()
let l:branchname = GitBranch()
return strlen(l:branchname) > 0?"  ".l:branchname." ":""
endfunction

" Set status line display
set statusline=
set statusline+=%#PmenuSel#
set statusline+=%{StatuslineGit()}
set statusline+=%#LineNr#
set statusline+=\ %f
set statusline+=%m\ 
set statusline+=%=
set statusline+=%#CursorColumn#
set statusline+=\ %y
set statusline+=\ %{&fileencoding?&fileencoding:&encoding}
set statusline+=\[%{&fileformat}\]
set statusline+=\ %p%%
set statusline+=\ %l:%c
set statusline+=\ 

set modelines=0

"" Enable mouse
set mouse=a

"" Set the wrapping.
set wrap
set textwidth=80
set colorcolumn=+1
set linebreak
set showbreak=+++

"" Set tab to space indent and the number of spaces.
set expandtab
set tabstop=2
set softtabstop=2
set shiftwidth=2
set autoindent
set backspace=indent,eol,start

"" not sure what this does.
set list
set listchars=tab:>\ ,trail:•,extends:#,nbsp:.

highlight Normal guibg=none
