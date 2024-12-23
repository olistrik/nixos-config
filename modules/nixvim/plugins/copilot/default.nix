{ lib, config, ... }:
with lib;
with lib.olistrik;
with lib.olistrik.nixvim;
mkPlugin "copilot" {
  inherit config;

  plugins = {
    # copilot-lua = {
    #   enable = true;
    #   panel.keymap.open = "<A-CR>";
    #   panel.layout.position = "right";
    #   # panel.enabled = false;
    #   # suggestion.enabled = false;
    # };

    # copilot-lualine = {
    #   enable = true;
    # };

    # lualine = {
    #   sections = {
    #     lualine_x = lib.mkBefore [ "copilot" ];
    #   };
    # };

    # copilot-cmp.enable = true;
    # cmp.settings.sources = [
    #   { name = "copilot"; }
    #   { name = "nvim_lsp"; }
    #   { name = "buffer"; }
    #   { name = "path"; }
    # ];
  };
}
