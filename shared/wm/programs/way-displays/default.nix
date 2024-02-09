{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    (pkgs.writeScriptBin
      "way-displays"
      ''
        #/bin/sh

        if [ $# -eq 0 ]; then 
          sleep 1 # give Hyprland a moment to set its defaults

          ${pkgs.way-displays}/bin/way-displays > "/tmp/way-displays.''${XDG_VTNR}.''${USER}.log" 2>&1
        else
          ${pkgs.way-displays}/bin/way-displays $@
        fi
      '')
  ];
}
