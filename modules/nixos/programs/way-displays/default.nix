{ lib, config, pkgs, ... }:
with lib;
with lib.olistrik;
let
  # TODO: modularize
  cfg = config.olistrik.programs.way-displays;
in
{
  options.olistrik.programs.way-displays = basicOptions "way-displays";

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      (writeScriptBin
        "way-displays"
        ''
          #/bin/sh

          if [ $# -eq 0 ]; then 
            sleep 1 # give Hyprland a moment to set its defaults

            ${way-displays}/bin/way-displays > "/tmp/way-displays.''${XDG_VTNR}.''${USER}.log" 2>&1
          else
            ${way-displays}/bin/way-displays $@
          fi
        '')
    ];
  };
}
