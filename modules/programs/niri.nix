{
  nixos.programs.niri =
    { my, pkgs, ... }:
    {
      imports = with my.modules.nixos.programs; [
        swayidle
        swaybg
      ];

      programs.niri = {
        enable = true;
        useNautilus = false;
      };

      environment.systemPackages = with pkgs; [
        # X11 compatibility; niri starts and manages it automatically.
        xwayland-satellite

        # Theming
        adwaita-icon-theme

        # Wallpaper utility
        wbg

        # locking
        gtk-session-lock
        swaylock
        swayidle

        # notification daemon (mako, dunst, ags).
        mako # temp until I get ags doing this.
        walker

        # auth agent. plasma-polkit-agent. Can be started with systemd.
        # pantheon.pantheon-agent-polkit
      ];

      services.greetd = {
        enable = true;
        settings = rec {
          initial_session = {
            command = "${pkgs.niri}/bin/niri-session";
            user = "oli";
          };
          default_session = initial_session;
        };
      };

      programs.dconf = {
        enable = true;
        profiles = {
          user.databases = [
            {
              settings = {
                "org/gnome/desktop/interface" = {
                  color-scheme = "prefer-dark";
                  gtk-theme = "Adwaita";
                  icon-theme = "Adwaita";
                };
              };
            }
          ];
        };
      };

      environment.sessionVariables = {
        NIXOS_OZONE_WL = "1";
        _JAVA_AWT_WM_NONREPARENTING = "1";
      };
    };
}
