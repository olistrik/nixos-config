{
  nixos.programs.ags =
    {
      my,
      lib,
      pkgs,
      ...
    }:
    let
      # passing pkgs makes ags-config, and astal-labs under it, follow our nixpkgs
      ags-config = (import my.sources.ags-config { inherit pkgs; }).default;
    in
    {
      systemd.user.services.ags = {
        description = "Desktop shell";
        bindsTo = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        requisite = [ "graphical-session.target" ];
        wantedBy = [ "graphical-session.target" ];

        startLimitIntervalSec = 10;
        startLimitBurst = 5;
        serviceConfig = {
          # needs NIRI_SOCKET, which niri imports into the user environment
          ExecStart = lib.getExe ags-config;
          Restart = "on-failure";
        };
      };
    };
}
