{ lib, config, pkgs, ... }:
with lib;
with lib.olistrik;
let
  cfg = config.olistrik.wayland.xwayland-satellite;
in
{
  options.olistrik.wayland.xwayland-satellite = with types; {
    enable = mkEnableOption "xwayland-satellite service";
    package = mkOpt package pkgs.xwayland-satellite "Which package to use.";
    display = mkOpt str ":0" "Display to use for XWayland";
  };

  config = mkIf cfg.enable {
    # TODO: How the fuck do I get set DISPLAY generically if niri keeps unsetting it.
    environment.sessionVariables = {
      XWAYLAND_DISPLAY = cfg.display;
    };
    systemd.user.services = {
      xwayland-satellite = {
        description = "XWayland Satellite";
        bindsTo = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        requisite = [ "graphical-session.target" ];
        wantedBy = [ "graphical-session.target" ];

        startLimitIntervalSec = 10;
        startLimitBurst = 5;

        serviceConfig = {
          Type = "notify";
          NotifyAccess = "all";
          ExecStart = "${cfg.package}/bin/xwayland-satellite ${cfg.display}";
          StandardOutput = "journal";
          Restart = "on-failure";
        };
      };
    };
  };
}
