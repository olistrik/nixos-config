{ lib, config, pkgs, ... }:
with lib;
with lib.olistrik;
let
  cfg = config.olistrik.wm.hyperland;
in
{
  options.olistrik.wm.hyperland = basicOptions "Hyprland";

  config = mkIf cfg.enable {
    programs.hyprland = enabled;
    olistrik.programs = {
      waybar = enabled;
      way-displays = enabled;
    };

    security.pam.services.swaylock = { };

    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
      ];
      xdgOpenUsePortal = true;
    };

    services.greetd = {
      enable = true;
      settings = rec {
        initial_session = {
          command = "${config.programs.hyprland.package}/bin/Hyprland";
          user = "oli";
        };
        default_session = initial_session;
      };
    };

    # FROM SWAY:
    # extraSessionCommands = ''
    #		export MOZ_ENABLE_WAYLAND=1
    #		export _JAVA_AWT_WM_NONREPARENTING=1
    #		systemctl --user import-environment
    # '';

    environment.systemPackages = with pkgs; [
      hyprpaper
      swaylock
      swayidle
      wofi
      xwayland
      grim
      jq
      slurp
      wl-clipboard
      playerctl
    ];

    environment.sessionVariables.NIXOS_OZONE_WL = "1";
  };
}
