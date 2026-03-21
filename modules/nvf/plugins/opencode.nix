{
  nvf.plugins.opencode =
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
      inherit (options.vim.assistant.opencode) mappings;
      cfg = config.vim.assistant.opencode;
      keys = cfg.mappings;

    in
    {
      options.vim.assistant.opencode = {
        enable = mkEnableOption "opencode.nvim";
        setupOpts = mkPluginSetupOption "opencode" { };

        mappings = {
        };
      };

      config.vim = lib.mkIf cfg.enable {
        extraPlugins.opencode = {
          package = pkgs.vimUtils.buildVimPlugin {
            pname = "opencode.nvim";
            version = "2026-03-03";
            src = pkgs.fetchFromGitHub {
              owner = "sudo-tee";
              repo = "opencode.nvim";
              rev = "3e890ae389ae6d01bbb477f32a54216d20c55e47";
              sha256 = "sha256-fBKz2p4QMmmGhxmAqjO1eVlAo7dGMAFSgzXnbmAPAzM=";
            };

            dependencies = with pkgs.vimPlugins; [
              plenary-nvim
            ];
          };

          setup = "require('opencode').setup(${toLuaObject cfg.setupOpts})";
        };
      };
    };

  nvf.config.opencode =
    { my, ... }:
    {
      imports = [ my.modules.nvf.plugins.opencode ];

      vim.assistant.opencode = {
        enable = true;
      };
    };

  nvf.config.keymaps = {
  };
}
