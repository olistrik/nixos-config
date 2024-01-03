# Install and configure neovim + plugins.
{ pkgs, lib, ... }:
let nvim = pkgs.olistrik.nvim;
in {
  environment.variables.EDITOR = "nvim";
  environment.systemPackages = [ nvim ] ++ nvim.additionalPackages;
}
