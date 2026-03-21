{
  nixos.programs.swaybg =
    {
      my,
      lib,
      pkgs,
      ...
    }:
    let
      inherit (my.lib.attrsets) attrsToArgs;
    in
    {
      systemd.user.services = {
        swaybg = {
          description = "Wayland Background Manager";
          bindsTo = [ "graphical-session.target" ];
          partOf = [ "graphical-session.target" ];
          after = [ "graphical-session.target" ];
          requisite = [ "graphical-session.target" ];
          wantedBy = [ "graphical-session.target" ];

          startLimitIntervalSec = 10;
          startLimitBurst = 5;
          script =
            let
              args = attrsToArgs {
                image = "$HOME/.wallpaper";
                mode = "fill"; # TODO: probably shouldn't be here.
              };
            in
            ''
              #!/bin/sh
              exec ${pkgs.swaybg}/bin/swaybg ${args}
            '';

          serviceConfig = {
            Restart = "on-failure";
          };
        };
      };
    };
}
