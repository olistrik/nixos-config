{
  nixos.programs.way-displays =
    {
      lib,
      pkgs,
      ...
    }:
    {
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
            "${pkgs.way-displays}/bin/way-displays"
            "-L error"
          ];

          Restart = "on-failure";
        };
      };
    };
}
