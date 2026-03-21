{
  nvf.plugins.notebook-navigator =
    {
      pkgs,
      lib,
      config,
      options,
      ...
    }:
    let
      inherit (lib.options) mkEnableOption;
      inherit (lib.generators) mkLuaInline;
      inherit (lib.nvim.types) mkPluginSetupOption;
      inherit (lib.nvim.binds) mkMappingOption mkKeymap;
      inherit (lib.nvim.lua) toLuaObject;
      inherit (options.vim.assistant.notebook-navigator) mappings;
      cfg = config.vim.assistant.notebook-navigator;
      keys = cfg.mappings;

    in
    {
      options.vim.assistant.notebook-navigator = {
        enable = mkEnableOption "notebook-navigator.nvim";
        setupOpts = mkPluginSetupOption "notebook-navigator" { };

        mappings = {
          runCell = mkMappingOption "Run code cell [Notebook Navigator]" "<leader>X";
          runAndMove = mkMappingOption "Run code cell and move to next [Notebook Navigator]" "<leader>x";
        };
      };

      config.vim = lib.mkIf cfg.enable {
        extraPlugins."molten.nvim" = {
          package = pkgs.vimPlugins.molten-nvim;
        };

        withNodeJs = true;
        withRuby = true;
        withPython3 = true;

        extraPackages = with pkgs; [
          imagemagick
        ];
        luaPackages = [
          "magick"
        ];
        python3Packages = [
          "pynvim"
          "jupyter-client"
          "cairosvg"
          "ipython"
          "nbformat"
        ];

        extraPlugins.notebook-navigator = {
          package = pkgs.vimUtils.buildVimPlugin {
            pname = "NotebookNavigator.nvim";
            version = "2025-12-24";
            src = pkgs.fetchFromGitHub {
              owner = "vandalt";
              repo = "NotebookNavigator.nvim";
              rev = "3bcffd2d57dffe76a2745da993176e23f497005f";
              sha256 = "sha256-agpTshwZhFHEMuANUKkqHIO1h5x8XFQHa5vWGo8ylrw=";
            };
          };

          setup = "require('notebook-navigator').setup(${toLuaObject cfg.setupOpts})";
        };
        keymaps = [
          (mkKeymap "n" keys.runCell "require('notebook-navigator').run_cell" {
            lua = true;
            desc = mappings.runCell.description;
          })
          (mkKeymap "n" keys.runAndMove "require('notebook-navigator').run_and_move" {
            lua = true;
            desc = mappings.runAndMove.description;
          })
        ];
      };
    };
  nvf.config.notebook-navigator =
    { my, ... }:
    {
      imports = [ my.modules.nvf.plugins.notebook-navigator ];

      vim.assistant.notebook-navigator = {
        enable = true;
      };
    };
}
