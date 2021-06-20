# Install and configure neovim + plugins.

{pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    ripgrep
  ];
  programs.neovim = {
    package = pkgs.neovim-nightly;
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    runtime = {
      "parser/tsx.so".source = "${pkgs.tree-sitter.builtGrammars.tree-sitter-tsx}/parser";
      "parser/nix.so".source = "${pkgs.tree-sitter.builtGrammars.tree-sitter-nix}/parser";
      "parser/rb.so".source = "${pkgs.tree-sitter.builtGrammars.tree-sitter-ruby}/parser";
    };
    configure = {
      packages.myPlugins = with pkgs.unstable.vimPlugins; {
        start = [
          # Language Support
          vim-nix
          vim-pandoc
          vim-pandoc-syntax
          vim-ruby
          vim-rails
          plantuml-syntax
          i3config-vim
          typescript-vim
          vim-jsx-typescript

          vim-table-mode

          # QOL
          vim-gitgutter
          vim-repeat
          auto-pairs
          vim-surround

          # File browsing
          nerdtree
          nerdtree-git-plugin
          fzf-vim

          ###########
          # 0.5 stuff

          # Telescope
          popup-nvim
          plenary-nvim
          telescope-nvim

          # Treesitter
          nvim-treesitter

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

      "" Set tab width for C++
      autocmd FileType cpp setlocal textwidth=78 tabstop=4 shiftwidth=4 softtabstop=4 expandtab

      " set .tsx and .jsx as typescriptreact
      autocmd BufNewFile,BufRead *.tsx,*.jsx set filetype=typescriptreact

      set backspace=indent,eol,start

      set list
      set listchars=tab:>\ ,trail:•,extends:#,nbsp:.


      " NERDTree
      "" close on file open
      let g:NERDTreeQuitOnOpen = 1

      "" Open on F2
      map <F2> :NERDTreeToggle<CR>

      "" close if only thing open.
      autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

      "" YouCompleteMe
      let g:ycm_min_num_of_chars_for_completion = 3
      let g:ycm_show_diagnostics_ui = 0

      "" FZF
      " let $FZF_DEFAULT_COMMAND = "find -L -not -path '*/\.git/*'"
      " nnoremap <silent> <C-p> :FZF<CR>

      "" Telescope
      nnoremap <silent> <C-p> <cmd>Telescope find_files<cr>
      nnoremap <silent> <C-f> <cmd>Telescope live_grep<cr>

      "" Treesitter
      lua <<EOF
      require'nvim-treesitter.configs'.setup {
        highlight = {
          enable = true,
        },
      }
      EOF

      "" Vim Table Mode
      function! s:isAtStartOfLine(mapping)
      let text_before_cursor = getline('.')[0 : col('.')-1]
      let mapping_pattern = '\V' . escape(a:mapping, '\')
      let comment_pattern = '\V' . escape(substitute(&l:commentstring,
      '%s.*$', ''', '''), '\')
      return (text_before_cursor =~? '^' . ('\v(' . comment_pattern . '\v)?') . '\s*\v' . mapping_pattern . '\v$')
      endfunction

      inoreabbrev <expr> <bar><bar>
              \ <SID>isAtStartOfLine('\|\|') ?
              \ '<c-o>:TableModeEnable<cr><bar><space><bar><left><left>' : '<bar><bar>'
      inoreabbrev <expr> __
              \ <SID>isAtStartOfLine('__') ?
              \ '<c-o>:silent! TableModeDisable<cr>' : '__'

      let g:table_mode_corner_corner='+'
      let g:table_mode_header_fillchar='='
      '';
    };
  };
}
