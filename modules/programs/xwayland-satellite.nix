{
  nixos.programs.xwayland-satellite =
    { self, pkgs, ... }:
    {
      # TODO: How the fuck do I get set DISPLAY generically if niri keeps unsetting it.
      environment.sessionVariables = {
        XWAYLAND_DISPLAY = ":0";
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
            ExecStart = "${pkgs.xwayland-satellite}/bin/xwayland-satellite :0";
            StandardOutput = "journal";
            Restart = "on-failure";
          };
        };
      };
    };
}
