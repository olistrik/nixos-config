{ pkgs, vimPlugins ? pkgs.vimPlugins, ... }:
with vimPlugins;
let
  addDeps = plugin: deps:
    plugin.overrideAttrs
    (old: { dependencies = (old.dependencies or [ ]) ++ deps; });

in {
  colorscheme = {
    plugin = neovim-ayu;
    config = "colorscheme";
  };

  lualine = {
    plugin = lualine-nvim;
    config = "lualine";
  };

  telescope = {
    plugin = addDeps telescope-nvim [
      nvim-web-devicons
      # telescope-fzf-native-nvim
      telescope-fzy-native-nvim
      telescope-file-browser-nvim
      # popup-nvim
      # plenary-nvim
    ];
    extern = with pkgs; [ ripgrep fd ];
    config = "telescope";
  };

  treesitter = {
    plugin =
      addDeps (nvim-treesitter.withPlugins (_: pkgs.tree-sitter.allGrammars)) [
        nvim-autopairs
        nvim-treesitter-textobjects
        nvim-ts-autotag
        vim-nix
        playground
      ];
    config = "treesitter";
  };

  nvim-tree = {
    plugin = nvim-tree-lua;
    config = "nvim-tree";
  };

  nvim-lspconfig = {
    plugin = addDeps nvim-lspconfig [
      lsp_extensions-nvim
      lsp_signature-nvim

      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path

    ];

    extern = with pkgs; [ rnix-lsp rust-analyzer gopls ];

    config = "lsp";
  };

  vim-easy-align = {
    plugin = vim-easy-align;
    config = "easy-align";
  };

  gitsigns-nvim = {
    plugin = gitsigns-nvim;
    config = "gitsigns";
  };

  nvim-autopairs = {
    plugin = nvim-autopairs;
    config = "nvim-autopairs";
  };

  nvim-colorizer = {
    plugin = nvim-colorizer-lua;
    config = "nvim-colorizer";
  };

  comment-nvim = {
    plugin = addDeps comment-nvim [ nvim-ts-context-commentstring ];
    config = "comment-nvim";
  };

  harpoon = {
    plugin = harpoon;
    config = "harpoon";
  };

  # indent-blankline-nvim = {
  #   plugin = indent-blankline-nvim;
  #   config = "indent-blankline";
  # };

  neoformat = {
    plugin = neoformat;
    config = "neoformat";
    extern = with pkgs;
      [
        nixfmt
        # custom.nodePackages.standard
        # custom.nodePackages.vscode-langservers-extracted
      ];
  };

  todo-comments = {
    plugin = todo-comments-nvim;
    config = "todo-comments";
  };

  luasnip.plugin = luasnip;

  # dressing-nvim = {
  #   plugin = pkgs.custom.dressing-nvim;
  #   config = "dressing";
  # };

  editorconfig-vim.plugin = editorconfig-vim;
  vim-surround.plugin = vim-surround;
  vim-repeat.plugin = vim-repeat;
  vim-fugitive.plugin = vim-fugitive;
}
