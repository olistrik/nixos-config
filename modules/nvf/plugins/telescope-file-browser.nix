{
  nvf.plugins.telescope-file-browser =
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
      inherit (lib.nvim.binds) mkMappingOption;
      inherit (lib.nvim.binds) mkKeymap;

      cfg = config.vim.telescope;
      keys = cfg.mappings;
      inherit (options.vim.telescope) mappings;
    in
    {
      options.vim.telescope = {
        mappings = {
          browseRelative = mkMappingOption "Relative file browser [Telescope]" "<leader><tab>";
        };

        fileBrowser = mkOption {
          default = { };
          type = submodule {
            options = {
              enable =
                mkEnableOption "telescope-file-browser.nvim: file browser extension for telescope.nvim"
                // {
                  default = true;
                };
            };
          };
        };
      };

      config.vim = lib.mkIf cfg.fileBrowser.enable {
        telescope = {
          extensions = [
            {
              name = "file_browser";
              packages = [ pkgs.vimPlugins.telescope-file-browser-nvim ];
              setup = { };
            }
          ];
        };
        lazy.plugins.telescope.keys = [
          (mkKeymap "n" keys.browseRelative "<cmd>Telescope file_browser path=%:p:h select_buffer=true<CR>" {
            desc = mappings.browseRelative.description;
          })
        ];
      };
    };
}
