{
  nvf.config.auto-hlsearch =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      inherit (lib.options) mkEnableOption;
      inherit (lib.nvim.types) mkPluginSetupOption;

      cfg = config.vim.auto-hlsearch;
    in
    {
      options.vim.auto-hlsearch = {
        enable = mkEnableOption "hlchun.nvim: alternative to indent-blankline" // {
          default = true;
        };
        setupOpts = mkPluginSetupOption "auto-hlsearch.nvim" { };
      };

      config.vim = lib.mkIf cfg.enable {
        extraPlugins = with pkgs.vimPlugins; {
          auto-hlsearch = {
            package = auto-hlsearch-nvim;
            setup =/* lua */ "require(" auto-hlsearch ").setup({})";
          };
        };
      };
    };
}
