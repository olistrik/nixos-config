{ config, helpers, pkgs, ... }:
helpers.vim-plugin.mkVimPlugin config {
  name = "copilot-lualine";
  defaultPackage = pkgs.olistrik.copilot-lualine;
  maintainers = [ ];
}
