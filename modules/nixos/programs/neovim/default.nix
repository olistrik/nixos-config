{ lib, config, ... }:
with lib;
with lib.olistrik;
let
  cfg = config.olistrik.programs.neovim;
  enablePlugins = plugins: lib.genAttrs plugins (_: { enable = true; });
in
{
  options.olistrik.programs.neovim = basicOptions "Neovim editor";

  imports = [ ./plugins ./autocmds ];
  config = mkIf cfg.enable {
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
  };
}
