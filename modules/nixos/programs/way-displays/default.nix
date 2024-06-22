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
            ${way-displays}/bin/way-displays -L debug > "/tmp/$LOG_FILE" 2>&1
          else
            ${way-displays}/bin/way-displays $@
          fi
        '')
    ];
  };
}
