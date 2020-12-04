# Install and configure neovim + plugins.

{pkgs, ...}:
{
  environment.variables = { EDITOR = "vim"; };
  environment.systemPackages = with pkgs; [
    (neovim.override {
      vimAlias = true;
      configure = {
        packages.myPlugins = with pkgs.vimPlugins; {
          start = [
            # Language Support
            vim-nix
            vim-pandoc
            vim-pandoc-syntax
            plantuml-syntax
            vim-jsx-pretty

            # QOL
            vim-gitgutter
            fzf-vim
            vim-repeat
            auto-pairs
            vim-surround
            nerdtree
            nerdtree-git-plugin

            # IDE
            ale
            YouCompleteMe

            # Themes
            ayu-vim
          ];
          opt = [];
        };
        customRC = ''
          " nvimrc

          syntax on
          set termguicolors
          let ayucolor="mirage"
          colorscheme ayu

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

          " Display different types of white spaces.
          set list
          set listchars=tab:›\ ,trail:•,extends:#,nbsp:.

          "" Enable mouse
          set mouse=a
          set ttyfast

          "" Use the system clipboard
          set clipboard=unnamedplus

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

          "" Set tab width for C++
          autocmd FileType cpp setlocal textwidth=78 tabstop=4 shiftwidth=4 softtabstop=4 expandtab
          autocmd FileType cpp let g:ale_cpp_gcc_options='--std=c++2a -Wall -pedantic'
          "" Set .ih files to cpp type
          augroup filetypedetect
            au BufRead,BufNewFile *.ih set filetype=cpp
          augroup END

          "" Set textwidth for pandoc
          autocmd FileType pandoc setlocal textwidth=80

          set backspace=indent,eol,start

          set list
          set listchars=tab:>\ ,trail:•,extends:#,nbsp:.

          "" WHY IS IT HIGHLIGHTED?
          nm <silent> <F1> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name")
              \ . '> trans<' . synIDattr(synID(line("."),col("."),0),"name")
              \ . "> lo<" . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name")
              \ . ">"<CR>

          " NERDTree
          "" close on file open
          let g:NERDTreeQuitOnOpen = 1

          "" Open on F2
          map <F2> :NERDTreeToggle<CR>

          "" close if only thing open.
          autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif


          " Ctrl+s to save
          nnoremap <c-s> :w<CR>
          inoremap <c-s> <ESC>:w<CR>
          vnoremap <c-s> <ESC>:w<CR>

          " Ctrl+q to quit
          nnoremap <c-q> :q<CR>
          inoremap <c-q> <ESC>:q<CR>
          vnoremap <c-q> <ESC>:q<CR>

          " Ctrl+p to FZF
          nnoremap <silent> <C-p> :FZF<CR>


          "" YouCompleteMe
          let g:ycm_min_num_of_chars_for_completion = 3
          let g:ycm_show_diagnostics_ui = 0


          '';
      };
    })];

  }

