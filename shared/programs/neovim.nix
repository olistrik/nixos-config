# Install and configure neovim + plugins.
{pkgs, lib, ...}:
let

  myNeovim = with pkgs.unstable; neovim-unwrapped.overrideAttrs (oldAttrs: {
    buildInputs = oldAttrs.buildInputs ++ [ ripgrep ];
  });

  configuredPlugins = with pkgs.vimPlugins; {
    colorscheme = {
      plugin = ayu-vim;
      config = ''
      set termguicolors
      let ayucolor="mirage"
      colorscheme ayu
      '';
    };

    nerdtree = {
      plugin = nerdtree;
      extras = [ nerdtree-git-plugin ];
      config = ''
      "" close on file open
      let g:NERDTreeQuitOnOpen = 1

      "" Open on F2
      map <F2> :NERDTreeToggle<CR>

      "" close if only thing open.
      autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
      '';
    };

    YouCompleteMe = {
      plugin = YouCompleteMe;
      config = ''
      let g:ycm_min_num_of_chars_for_completion = 3
      let g:ycm_show_diagnostics_ui = 0
      '';
    };

    fzf = {
      plugin = fzf-vim;
      config = ''
      let $FZF_DEFAULT_COMMAND = "find -L -not -path '*/\.git/*'"
      nnoremap <silent> <C-p> :FZF<CR>
      '';
    };

    telescope = {
      plugin = telescope-nvim;
      extras = [ popup-nvim plenary-nvim ];
      requires = with pkgs; [ ripgrep ];
      config = ''
      nnoremap <silent> <C-p> <cmd>Telescope find_files<cr>
      nnoremap <silent> <C-f> <cmd>Telescope live_grep<cr>
      '';
    };

    treesitter = {
      plugin = nvim-treesitter;
      config = ''
      lua <<EOF
      require'nvim-treesitter.configs'.setup {
        highlight = {
          enable = true,
        },
        indent = {
          enable = true,
        }
      }
      EOF
      '';
      # runtime = ( builtins.listToAttrs (
      #  lib.mapAttrsToList
      #      (name: value: {
      #      name = "parser/${lib.lists.last (lib.strings.splitString "-" name)}.so";
      #      value = { source = "${value}/parser"; };
      #      })
      #      pkgs.tree-sitter.builtGrammars
      # ));
    };
  };

  treeSitterRuntime = name: pkg: {
    "parser/${name}.so".source = "${pkg}/parser";
  };

  languages = with pkgs; with vimPlugins; with tree-sitter.builtGrammars; {
    golang = rec {
      suffix = "go";
      runtime = treeSitterRuntime suffix tree-sitter-go;
    };

    nix = rec {
      suffix = "nix";
      extras = [ vim-nix ];
      # runtime = treeSitterRuntime suffix tree-sitter-nix;
    };

    c = rec {
      suffix = "c";
      runtime = treeSitterRuntime suffix tree-sitter-c;
    };

    tsx = rec {
      suffix = "tsx";
      # extras = [ typescript-vim vim-jsx-typescript ];
      runtime = treeSitterRuntime suffix tree-sitter-tsx;
    };

    ruby = rec {
      suffix = "rb";
      extras = [ vim-rails ]; # Not sure if i need this?
      requires = with pkgs.kranex; [ rubocop-sdv ];
      runtime = treeSitterRuntime suffix tree-sitter-ruby;
    };

    yaml = rec {
      suffix = "yaml";
      runtime = treeSitterRuntime suffix tree-sitter-yaml;
    };
  };

  plugins = with configuredPlugins; with languages; [
    colorscheme

    # file browsing
    telescope # fzf
    nerdtree

    # completion
    # YouCompleteMe

    # linting
    treesitter

    # languages
  ] ++ lib.mapAttrsToList (name: value: value) languages;

  runtime = lib.fold (x: y: lib.mergeAttrs x y ) {} (builtins.catAttrs "runtime" plugins);

in {
  environment.systemPackages = builtins.concatLists (builtins.catAttrs "requires" plugins);

  programs.neovim = {
    package = pkgs.unstable.neovim-unwrapped;
    enable = true;

    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    runtime = builtins.trace runtime runtime;

    configure = {
      packages.myPlugins = with pkgs.unstable.vimPlugins; {
        start =
          builtins.catAttrs "plugin" plugins ++
          builtins.concatLists (builtins.catAttrs "extras" plugins) ++ [
            # Language Support
            vim-pandoc
            vim-pandoc-syntax
            plantuml-syntax
            i3config-vim

            # QOL
            vim-gitgutter
            vim-repeat
            auto-pairs
            vim-surround
            #vim-table-mode

            # IDE
            ale
          ];

        opt = [];
      };

      customRC = builtins.concatStringsSep "\n" (builtins.catAttrs "config" plugins) + ''
      " nvimrc

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

      "" Set tab width for C++
      autocmd FileType cpp setlocal textwidth=78 tabstop=4 shiftwidth=4 softtabstop=4 expandtab

      " set .tsx and .jsx as typescriptreact
      autocmd BufNewFile,BufRead *.tsx,*.jsx set filetype=typescriptreact

      set backspace=indent,eol,start

      set list
      set listchars=tab:>\ ,trail:•,extends:#,nbsp:.
      '';
    };
  };
}
