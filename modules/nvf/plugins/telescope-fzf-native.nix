{
  nvf.plugins.telescope-fzf-native =
    {
      pkgs,
      config,
      lib,
      options,
      ...
    }:
    let
      inherit (lib.options) mkOption mkEnableOption;
      inherit (lib.types) submodule;

      cfg = config.vim.telescope;
    in
    {
      options.vim.telescope = {
        fzfNative = mkOption {
          default = { };
          type = submodule {
            options = {
              enable = mkEnableOption "telescope-fzf-native.nvim: fzf sorter for telescope.nvim written in c" // {
                default = true;
              };
            };
          };
        };
      };

      config.vim = {
        telescope = lib.mkIf cfg.fzfNative.enable {
          extensions = [
            {
              name = "fzf";
              packages = [ pkgs.vimPlugins.telescope-fzf-native-nvim ];
              setup = { };
            }
          ];
        };
      };
    };
}
