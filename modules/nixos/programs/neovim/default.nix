{ lib, pkgs, config, ... }:
with lib;
with lib.olistrik;
let
  cfg = config.olistrik.programs.neovim;
in
{
  options.olistrik.programs.neovim.enable = mkEnableOption "Enable the base neovim editor";

  config = mkIf cfg.enable {
    environment.variables.EDITOR = "nvim";
    environment.systemPackages = with pkgs; [ nixvim ];
  };
}
