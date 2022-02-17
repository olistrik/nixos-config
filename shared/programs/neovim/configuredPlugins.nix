{pkgs, vimPlugins ? pkgs.vimPlugins}:
with vimPlugins; {
    colorscheme = {
      plugin = neovim-ayu;
      config = ./config/plugin/colorscheme.lua;
    };

    telescope = {
      plugin = telescope-nvim;
      extras = [ popup-nvim plenary-nvim ];
      requires = with pkgs; [ ripgrep ];
      config = ./config/plugin/telescope.lua;
    };

    nerdtree = {
      plugin = nerdtree;
      extras = [ nerdtree-git-plugin ];
      config = ./config/plugin/nerdtree.vim;
    };

    treesitter = {
      plugin = nvim-treesitter.withPlugins (
          plugins: pkgs.tree-sitter.allGrammars # maybe on a per language basis?
      );
      config = ./config/plugin/treesitter.lua;
    };

    ts-autotag = {
      plugin = nvim-ts-autotag; # maintained by me
      config = ./config/plugin/ts-autotag.lua;
    };

    compe = {
      plugin = nvim-compe;
      extras = [];
      config = ./config/plugin/compe.vim;
    };

    lspconfig = {
      plugin = nvim-lspconfig;
      extras = [ lsp_extensions-nvim ];
      config = ./config/plugin/lspconfig.vim;
    };

    nix = {
      requires = with pkgs; [ rnix-lsp ];
      extras = [ vim-nix ];
      config = ./config/plugin/nix.lua;
    };

    rust = {
      requires = with pkgs; [  ];
      config = ./config/plugin/rust.vim;
    };
}
