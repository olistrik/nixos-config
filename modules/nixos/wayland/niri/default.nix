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
    };

    environment.systemPackages = with pkgs; [
      cfg.package

      # Theming
      adw-gtk3

      # Wallpaper utility
      wbg

      # locking
      gtk-session-lock
      swaylock
      swayidle

      # notification daemon (mako, dunst, ags).
      mako # temp until I get ags doing this.

      # auth agent. plasma-polkit-agent. Can be started with systemd.
      pantheon.pantheon-agent-polkit

      # legacy support
      xwayland-satellite
    ];

    security.pam.services.swaylock = { };

    environment.etc = {
      "xdg/gtk-2.0/gtkrc".text = ''
        gtk-theme-name = "adw-gtk3-dark"
      '';
      "xdg/gtk-3.0/settings.ini".text = ''
        [Settings]
        gtk-theme-name = adw-gtk3-dark
      '';
    };

    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-gnome
      ];

      config = {
        common = {
          default = [ "gtk" ];
        };
        niri = {
          default = [ "gnome" "gtk" ];
          "org.freedesktop.impl.portal.Secret" = [
            "gnome-keyring"
          ];
        };
      };
    };

    services.gnome.gnome-keyring = {
      enable = true;
    };

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

    # systemd.packages = [ pkgs.niri ];
    # systemd.user.services.niri.wantedBy = [ "default.target" ];

    programs.dconf = {
      enable = true;
      profiles = {
        user.databases = [{
          settings = {
            "org/gnome/desktop/interface" = {
              color-scheme = "prefer-dark";
              gtk-theme = "adw-gtk3-dark";
            };
          };
        }];
      };
    };

    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      _JAVA_AWT_WM_NONREPARENTING = "1";

      # TODO: this should be synced by xwayland-satellite
      DISPLAY = ":0";
    };
  };
}

