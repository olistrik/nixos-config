{ lib, config, ... }:
with lib;
with lib.olistrik;
with lib.olistrik.nixvim;
mkPlugin "copilot" {
  inherit config;

  plugins = {
    copilot-lua = {
      enable = true;
      panel.enabled = false;
      suggestion.enabled = false;
    };

    copilot-cmp.enable = true;
    cmp.settings.sources = [
      { name = "copilot"; }
      { name = "nvim_lsp"; }
      { name = "buffer"; }
      { name = "path"; }
    ];
  };
}
