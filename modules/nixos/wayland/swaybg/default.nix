{ lib, config, pkgs, ... }:
with lib;
with lib.olistrik;
let
  cfg = config.olistrik.wayland.swaybg;
in
{
  # TODO: configure here, not in $HOME.
  options.olistrik.wayland.swaybg = with types; {
    enable = mkEnableOption "swaybg service";
    package = mkOpt package pkgs.swaybg "Which package to use.";
    image = mkOpt str "$HOME/.wallpaper" "Path to the wallpaper.";
    mode = mkOpt (enum [ "stretch" "fit" "fill" "center" "tile" "solid_color" ]) "fill" "Background Mode (stretch, fit, fill, center, tile, or solid_color)";
  };

  config = mkIf cfg.enable {
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
            args = attrsToArgs { inherit (cfg) image mode; };
          in
          ''
            #!/bin/sh
            exec ${cfg.package}/bin/swaybg ${args}
          '';

        serviceConfig = {
          Restart = "on-failure";
        };
      };
    };
  };
}
