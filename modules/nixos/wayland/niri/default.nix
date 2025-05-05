{ lib, config, pkgs, ... }:
with lib;
with lib.olistrik;
let
  cfg = config.olistrik.wayland.niri;
in
{
  options.olistrik.wayland.niri = {
    enable = mkEnableOption "niri";
    package = mkOpt types.package pkgs.niri "Which Niri package to use.";
  };


  config = mkIf cfg.enable {
    olistrik.wayland = {
      way-displays.enable = true;
      xwayland-satellite.enable = true;
      swayidle.enable = true;
      swaybg.enable = true;
      # wbg.enable = true;
    };

    programs.niri.enable = true;

    xdg.portal = {
      config.niri = {
        # Fix for chromium based apps getting upset because I don't use Nautilus
        "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];

        # Apparently messing with this unsets the Niri defaults. Not sure why.
        # https://github.com/YaLTeR/niri/blob/7cfecf4b1b9b8c11c80061fb31926f888228499d/resources/niri-portals.conf#L3
        default = [ "gnome" "gtk" ];
        "org.freedesktop.impl.portal.Access" = [ "gtk" ];
        "org.freedesktop.impl.portal.Notification" = [ "gtk" ];
        "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
      };
    };

    environment.systemPackages = with pkgs; [
      # Theming
      yaru-theme

      # Wallpaper utility
      wbg

      # locking
      gtk-session-lock
      swaylock
      swayidle

      # notification daemon (mako, dunst, ags).
      mako # temp until I get ags doing this.

      # auth agent. plasma-polkit-agent. Can be started with systemd.
      # provided by niri-flake
      # pantheon.pantheon-agent-polkit
    ];

    # done by niri-flake
    # security.pam.services.swaylock = { };

    # environment.etc = {
    #   "xdg/gtk-2.0/gtkrc".text = ''
    #     gtk-theme-name = "Yaru-dark"
    #     gtk-icon-theme-name = "Yaru-dark"
    #   '';
    #   "xdg/gtk-3.0/settings.ini".text = ''
    #     [Settings]
    #     gtk-theme-name = Yaru-dark
    #     gtk-icon-theme-name = Yaru-dark
    #   '';
    # };

    # Provided by niri-flake?
    # xdg.portal = {
    #   enable = true;
    #   xdgOpenUsePortal = true;
    #   extraPortals = with pkgs; [
    #     xdg-desktop-portal-gtk
    #     xdg-desktop-portal-gnome
    #   ];
    #
    #   config = {
    #     common = {
    #       default = [ "gtk" ];
    #     };
    #     niri = {
    #       default = [ "gnome" "gtk" ];
    #       "org.freedesktop.impl.portal.Secret" = [
    #         "gnome-keyring"
    #       ];
    #     };
    #   };
    # };
    #
    # services.gnome.gnome-keyring = {
    #   enable = true;
    # };

    services.greetd = {
      enable = true;
      settings = rec {
        initial_session = {
          command = "${cfg.package}/bin/niri-session";
          user = "oli";
        };
        default_session = initial_session;
      };
    };

    programs.dconf = {
      enable = true;
      profiles = {
        user.databases = [{
          settings = {
            "org/gnome/desktop/interface" = {
              color-scheme = "prefer-dark";
              gtk-theme = "Yaru-dark";
              gtk-icon-theme = "Yaru-dark";
            };
          };
        }];
      };
    };

    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      _JAVA_AWT_WM_NONREPARENTING = "1";
    };
  };
}

