{ lib, config, pkgs, ... }:
with lib;
with lib.olistrik;
let
  cfg = config.olistrik.wayland.swayidle;
in
{
  # TODO: configure here, not in $HOME.
  options.olistrik.wayland.swayidle = with types; {
    enable = mkEnableOption "swayidle service";
    package = mkOpt package pkgs.swayidle "Which package to use.";
  };

  config = mkIf cfg.enable {
    systemd.user.services = {
      swayidle = {
        description = "Swayidle Locker";
        bindsTo = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        requisite = [ "graphical-session.target" ];
        wantedBy = [ "graphical-session.target" ];

        startLimitIntervalSec = 10;
        startLimitBurst = 5;

        # TODO: make it configurable so this isn't necessary.
        path = with pkgs; [ swaylock niri ];

        serviceConfig = {
          ExecStart = "${cfg.package}/bin/swayidle";
          Restart = "on-failure";
        };
      };
    };
  };
}
