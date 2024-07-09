{ lib, config, pkgs, ... }:
with lib;
with lib.olistrik;
let
  # TODO: modularize
  cfg = config.olistrik.wayland.way-displays;
in
{
  options.olistrik.wayland.way-displays = {
    enable = mkOpt types.bool false "Whether to enable way-displays.";
    package = mkOpt types.package pkgs.way-displays "Which way-displays package to use.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      (writeShellScriptBin
        "way-displays"
        ''
          LOG_FILE="way-displays.$XDG_VTNR.log"
          
          if [ -z "$XDG_VTNR" ]; then
            VT="$(tty | sed -E 's,(^/dev|/),,g')"
            LOG_FILE="way-displays.$VT.log"
          fi

          echo "way-displays logging to $LOG_FILE"

          if [ $# -eq 0 ]; then 
            sleep 1 # give Hyprland a moment to set its defaults
            ${cfg.package}/bin/way-displays -L debug > "/tmp/$LOG_FILE" 2>&1
          else
            ${cfg.package}/bin/way-displays $@
          fi
        '')
    ];
  };
}
