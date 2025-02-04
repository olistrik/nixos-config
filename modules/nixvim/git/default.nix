{ config, lib, ... }:
with lib;
with lib.olistrik;
let
  cfg = config.olistrik.git;
in
{
  options.olistrik.git = {
    enable = mkEnableOption "git config";
  };

  config = mkIf cfg.enable {
    plugins = {
      gitsigns = {
        enable = true;
        settings = {
          current_line_blame = true;
        };
      };

      # TODO: Better Diffs, MergeTool, Etc.
      # fugitive = enabled; # might work for this?
    };
  };
}
