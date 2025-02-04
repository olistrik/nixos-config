{ config, pkgs, lib, ... }:
with lib;
with lib.olistrik;
let
  cfg = config.olistrik.codecompanion;
in
{
  options.olistrik.codecompanion = {
    enable = mkEnableOption "codecompanion config";
  };

  config = mkIf cfg.enable {
    extraPlugins = with pkgs.vimPlugins; [
      codecompanion-nvim
    ];

    extraConfigLua = ''
      require("codecompanion").setup({
        strategies = {
          chat = {
            adapter = "copilot",
          },
          inline = {
            adapter = "copilot",
          },
        },
        display = {
          chat = {
            window = {
              position = "right",
              width = 0.35,
            },
          },
        },
      });

      vim.cmd([[cab cc CodeCompanion]]);
    '';

    keymaps =
      let
        set = mode: key: action: options: {
          inherit mode key action options;
        };
      in
      [
        (set [ "n" "v" ] "<C-a>" "<cmd>CodeCompanionActions<cr>" {
          noremap = true;
          silent = true;
        })
        (set [ "n" "v" ] "<LocalLeader>a" "<cmd>CodeCompanionChat Toggle<cr>" {
          noremap = true;
          silent = true;
        })
        (set [ "v" ] "ga" "<cmd>CodeCompanionChat Add<cr>" {
          noremap = true;
          silent = true;
        })
      ];
  };
}
