{

  nvf.config.theming = {
    vim.theme = {
      enable = true;
      name = "tokyonight";
      style = "night";
      transparent = true;
    };
  };

  nvf.theme.ayu-mirage =
    { pkgs, ... }:
    {

      config.vim = {
        extraPlugins = {
          neovim-ayu = {
            package = pkgs.vimPlugins.neovim-ayu;
            setup = /* lua */ ''
              require("ayu").setup({
              	mirage = true,
              	terminal = false,
              	overrides = {
              		-- LspReferenceText = {
              		-- 	-- link = "CursorSearch",
              		-- 	bg = "#57443A",
              		-- 	-- fg = "#1F2430",
              		-- },
              	},
              })
              require("ayu").colorscheme()
            '';
          };
        };

        statusline.lualine.theme = "ayu_mirage";

        # not sure how to add ayu to themes.
        # theme = {
        #   enable = true;
        #   name = "base16";
        # };
      };
    };
}
