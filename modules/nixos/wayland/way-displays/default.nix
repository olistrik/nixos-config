{ lib, config, pkgs, ... }:
with lib;
with lib.olistrik;
let
  cfg = config.olistrik.wayland.way-displays;
in
{
  options.olistrik.wayland.way-displays = with types; {
    enable = mkEnableOption "way-displays service";
    package = mkOpt package pkgs.way-displays "Which way-displays package to use.";
    logLevel = mkOpt (enum [ "debug" "info" "warning" "error" ]) "debug" "The log level for way-displays";
  };

  config = mkIf cfg.enable {
    systemd.user.services.way-displays = {
      description = "Wayland Display Manager";

      partOf = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      requisite = [ "graphical-session.target" ];
      wantedBy = [ "graphical-session.target" ];

      startLimitIntervalSec = 10;
      startLimitBurst = 5;

      serviceConfig = {
        ExecStart = lib.escapeShellArgs [
          "${cfg.package}/bin/way-displays"
          "-L${cfg.logLevel}"
        ];

        Restart = "on-failure";
      };
    };
  };
}
