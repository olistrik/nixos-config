{pkgs, vimPlugins ? pkgs.vimPlugins}:
with vimPlugins; {
    colorscheme = {
      plugin = neovim-ayu;
      config = ./configs/colorscheme.lua;
    };

    telescope = {
      plugin = telescope-nvim;
      extras = [ popup-nvim plenary-nvim ];
      requires = with pkgs; [ ripgrep ];
      config = ./configs/telescope.lua;
    };

    nerdtree = {
      plugin = nerdtree;
      extras = [ nerdtree-git-plugin ];
      config = ./configs/nerdtree.vim;
    };

    treesitter = {
      plugin = nvim-treesitter.withPlugins (
          plugins: pkgs.tree-sitter.allGrammars # maybe on a per language basis?
      );
      config = ./configs/treesitter.lua;
    };

    ts-autotag = {
      plugin = nvim-ts-autotag; # maintained by me
        config = ./configs/ts-autotag.lua;
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

    compe = {
      plugin = nvim-compe;
      extras = [];
      config = ./configs/compe.vim;
    };

    lspconfig = {
      plugin = nvim-lspconfig;
      extras = [ lsp_extensions-nvim ];
      config = ./configs/lspconfig.vim;
    };
  
    rust = {
      requires = with pkgs; [ rust-analyzer ];
      config = ./configs/rust.vim;
    };
}
