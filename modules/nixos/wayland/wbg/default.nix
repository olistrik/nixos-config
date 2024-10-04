{ lib, config, pkgs, ... }:
with lib;
with lib.olistrik;
let
  cfg = config.olistrik.wayland.wbg;
in
{
  # TODO: configure here, not in $HOME.
  options.olistrik.wayland.wbg = with types; {
    enable = mkEnableOption "wbg service";
    package = mkOpt package pkgs.wbg "Which package to use.";
    wallpaperPath = mkOpt str "$HOME/.wallpaper" "Path to the wallpaper.";
  };

  config = mkIf cfg.enable {
    systemd.user.services = {
      wbg = {
        description = "Wayland Background Manager";
        bindsTo = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        requisite = [ "graphical-session.target" ];
        wantedBy = [ "graphical-session.target" ];

        startLimitIntervalSec = 10;
        startLimitBurst = 5;
        script = ''
          #!/bin/sh
          exec ${cfg.package}/bin/wbg ${cfg.wallpaperPath}
        '';

        serviceConfig = {
          Restart = "on-failure";
        };
      };
    };
  };
}
