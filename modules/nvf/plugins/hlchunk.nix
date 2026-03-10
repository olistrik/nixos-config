{
  nvf.config.hlchunk =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      inherit (lib.options) mkEnableOption;
      inherit (lib.nvim.types) mkPluginSetupOption;

      cfg = config.vim.hlchunk;
    in
    {
      options.vim.hlchunk = {
        enable = mkEnableOption "hlchun.nvim: alternative to indent-blankline" // {
          default = true;
        };
        setupOpts = mkPluginSetupOption "hlchunk.nvim" { };
      };

      config.vim = lib.mkIf cfg.enable {
        extraPlugins = with pkgs.vimPlugins; {
          hlchunk = {
            package = hlchunk-nvim;
            setup = /* lua */ ''
              require("hlchunk").setup({
              	chunk = {
              		enable = false,
              		use_treesitter = true,
              		duration = 0,
              		delay = 100,
              	},
              	indent = {
              		enable = false,
              		chars = {
              			"│",
              			"¦",
              			"┆",
              			"┊",
              		},
              		ahead_lines = 4,
              	},
              	blank = {
              		enable = false,
              		priority = 1,
              	},
              })
            '';
          };
        };
      };
    };
}
