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
            vim-nix

            vim-gitgutter

            fzf-vim

            vim-repeat

            auto-pairs
            vim-surround

            ayu-vim
          ];
          opt = [];
        };
        customRC = ''
          " nvimrc

          syntax on
          set termguicolors
          let ayucolor="dark"
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

          set wrap
          set textwidth=80
          set colorcolumn=+1
          set linebreak
          set showbreak=+++

          set expandtab
          set tabstop=2
          set softtabstop=2
          set shiftwidth=2
          set autoindent

          set backspace=indent,eol,start

          set list
          set listchars=tab:>\ ,trail:•,extends:#,nbsp:.
        '';
      };
    })];

  }
