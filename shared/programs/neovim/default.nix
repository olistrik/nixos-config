{ ... }: {
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
      exrc = true;
    };

    plugins = {
      lualine.enable = true;
      telescope.enable = true;
      treesitter.enable = true;
      lsp.enable = true;
    };
  };
}
