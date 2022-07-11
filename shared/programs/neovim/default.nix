# Install and configure neovim + plugins.
{ pkgs, lib, ... }:
let nvim = pkgs.kranex.nvim;
in {
  environment.variables.EDITOR = "nvim";
  environment.systemPackages = [ nvim ] ++ nvim.additionalPackages;
}
