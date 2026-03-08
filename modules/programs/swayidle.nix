{
  nixos.programs.swayidle =
    { self, pkgs, ... }:
    {
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
          path = with pkgs; [
            swaylock
            niri
          ];

          serviceConfig = {
            ExecStart = "${pkgs.swayidle}/bin/swayidle";
            Restart = "on-failure";
          };
        };
      };
    };
}
