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

    lspconfig = {
      plugin = nvim-lspconfig;
      extras = [ lsp_extensions-nvim completion-nvim ];
      config = ''
        filetype plugin indent on

        " Set completeopt to have a better completion experience
        " :help completeopt
        " menuone: popup even when there's only one match
        " noinsert: Do not insert text until a selection is made
        " noselect: Do not select, force user to select one from the menu
        set completeopt=menuone,noinsert,noselect

        " Avoid showing extra messages when using completion
        set shortmess+=c

        " Always show signcolumn so that it doesnt (dis)appear when a new error happens
        set signcolumn=yes

        lua <<EOF
        local nvim_lsp = require'lspconfig'

        local on_attach = function(client)
          require'completion'.on_attach(client)
        end

        -- Register all the language servers
        nvim_lsp.rnix.setup { on_attach = on_attach }
        nvim_lsp.tsserver.setup { on_attach = on_attach }
        nvim_lsp.rust_analyzer.setup { on_attach = on_attach }

        -- Enable diagnostics
        vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
          vim.lsp.diagnostic.on_publish_diagnostics, {
            virtual_text = true,
            signs = true,
            update_in_insert = true,
          }
        )
        EOF

        " Code navigation shortcuts
        nnoremap <silent> gd    <cmd>lua vim.lsp.buf.definition()<CR>
        nnoremap <silent> K     <cmd>lua vim.lsp.buf.hover()<CR>
        nnoremap <silent> gD    <cmd>lua vim.lsp.buf.implementation()<CR>
        nnoremap <silent> <c-k> <cmd>lua vim.lsp.buf.signature_help()<CR>
        nnoremap <silent> 1gD   <cmd>lua vim.lsp.buf.type_definition()<CR>
        nnoremap <silent> gr    <cmd>lua vim.lsp.buf.references()<CR>
        nnoremap <silent> g0    <cmd>lua vim.lsp.buf.document_symbol()<CR>
        nnoremap <silent> gW    <cmd>lua vim.lsp.buf.workspace_symbol()<CR>
        nnoremap <silent> <c-]> <cmd>lua vim.lsp.buf.declaration()<CR>
        nnoremap <silent> ga    <cmd>lua vim.lsp.buf.code_action()<CR>

        " Use <Tab> and <S-Tab> to navigate through popup menu if it's open
        inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
        inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

        " use <Tab> as trigger keys
        imap <Tab> <Plug>(completion_smart_tab)
        imap <S-Tab> <Plug>(completion_smart_s_tab)

        " Set updatetime for CursorHold
        " 300ms of no cursor movement to trigger CursorHold
        set updatetime=300

        " Show diagnostic popup on cursor hold
        autocmd CursorHold * lua vim.lsp.diagnostic.show_line_diagnostics()

        " Goto previous/next diagnostic warning/error
        nnoremap <silent> g[ <cmd>lua vim.lsp.diagnostic.goto_prev()<CR>
        nnoremap <silent> g] <cmd>lua vim.lsp.diagnostic.goto_next()<CR>

        autocmd CursorMoved,InsertLeave,BufEnter,BufWinEnter,TabEnter,BufWritePost *
        \ lua require'lsp_extensions'.inlay_hints{ prefix = "", highlight = "Comment", enabled = {"TypeHint", "ChainingHint", "ParameterHint"} }
      '';
    };
  };

  treeSitterRuntime = name: pkg: {
    "parser/${name}.so".source = "${pkg}/parser";
  };

  lspConfig = name: ''
    lua << EOF
    local nvim_lsp = require'lspconfig'

    local on_attach = function(client)
      require'completion'.on_attach(client)
    end

    nvim_lsp.${name}.setup { on_attach = on_attach }
    EOF
  '';

  languages = with pkgs; with vimPlugins; with tree-sitter.builtGrammars; {
    golang = rec {
      suffix = "go";
      requires = [ gopls ];
      runtime = treeSitterRuntime suffix tree-sitter-go;
      config = lspConfig "gopls";
    };

    nix = rec {
      suffix = "nix";
      extras = [ vim-nix ];
      requires = [ rnix-lsp ];
      # runtime = treeSitterRuntime suffix tree-sitter-nix;
      config = lspConfig "rnix";
    };

    c = rec {
      suffix = "c";
      runtime = treeSitterRuntime suffix tree-sitter-c;
    };

    tsx = rec {
      suffix = "tsx";
      requires = [ nodePackages.typescript-language-server ];
      # extras = [ typescript-vim vim-jsx-typescript ];
      runtime = treeSitterRuntime suffix tree-sitter-tsx;
      config = lspConfig "tsserver";
    };

    ruby = rec {
      suffix = "rb";
      extras = [ vim-rails ]; # Not sure if i need this?
      requires = [ kranex.rubocop-sdv solargraph ];
      runtime = treeSitterRuntime suffix tree-sitter-ruby;
      config = (lspConfig "solargraph") + ''
        " Auto lint and fix ruby on save
        autocmd BufWritePost *.rb silent! !${kranex.rubocop-sdv}/bin/rubocop -A <afile>
        autocmd BufWritePost *.rb edit
        autocmd BufWritePost *.rb redraw!
      '';
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
    lspconfig
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
            # ale
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
