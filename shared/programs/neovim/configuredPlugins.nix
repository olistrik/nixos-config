{pkgs, vimPlugins ? pkgs.vimPlugins}:
with vimPlugins; {
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
        autocmd bufEnter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
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

    compe = {
      plugin = nvim-compe;
      extras = [];
      config = ''
        " Set completeopt to have a better completion experience
        " :help completeopt
        " menuone: popup even when there's only one match
        " noinsert: Do not insert text until a selection is made
        " noselect: Do not select, force user to select one from the menu
        set completeopt=menuone,noinsert,noselect


        lua <<EOF

        require'compe'.setup {
          enabled = true;
          autocomplete = true;
          debug = false;
          source = {
            path = true;
            buffer = true;
            nvim_lsp = true;
          };
        }

        EOF

        " TODO: Keybindings
        " Use <Tab> and <S-Tab> to navigate through popup menu if it's open
        " inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
        " inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

        " use <Tab> as trigger keys
        " imap <Tab> <Plug>(completion_smart_tab)
        " imap <S-Tab> <Plug>(completion_smart_s_tab)


      '';
    };

    lspconfig = {
      plugin = nvim-lspconfig;
      extras = [ lsp_extensions-nvim ];
      config = ''
        filetype plugin indent on

        " Avoid showing extra messages when using completion
        set shortmess+=c

        " Always show signcolumn so that it doesnt (dis)appear when a new error happens
        set signcolumn=yes

        lua <<EOF
        vim.lsp.set_log_level("debug")
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
  
}
