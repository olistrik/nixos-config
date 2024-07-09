{ lib, config, pkgs, ... }:
with lib;
with lib.olistrik;
let
  cfg = config.olistrik.wayland.ags;
in
{
  options.olistrik.wayland.ags = {
    enable = mkOpt types.bool false "Whether to enable AGS widgets.";
    package = mkOpt types.package pkgs.ags "Which AGS package to use.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      cfg.package
    ];
  };
}
