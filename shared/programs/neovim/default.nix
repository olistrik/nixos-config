{ lib, ... }:
let
  enablePlugins = plugins: lib.genAttrs plugins (_: { enable = true; });
in
{
  imports = [ ./plugins ./autocmds ];

  environment.variables.EDITOR = "nvim";
  programs.nixvim = {
    enable = true;

    colorschemes.ayu.enable = true;
    editorconfig.enable = true;

    clipboard = {
      register = [ "unnamed" "unnamedplus" ];
      providers.wl-copy.enable = true;
    };

    globals.mapleader = " ";

    options = {
      number = true;
      relativenumber = true;
      laststatus = 1;
      scrolloff = 5;
      incsearch = true;
      hlsearch = false;
      mouse = "nvchr";
      signcolumn = "yes";
    };

    plugins = enablePlugins [
      "lualine"
      "telescope"
      "treesitter"
      "lsp"
      "luasnip"
      "gitsigns"
      "gitblame"
      "nvim-autopairs"
      "nvim-colorizer"
      "comment-nvim"
      #"harpoon"
      "todo-comments"
      "surround"
      "fugitive"
      # "abolish"
      # "easy-align"
      # "vim-repeat"
    ];
  };
}
