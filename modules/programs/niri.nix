{
  nixos.programs.niri =
    {
      my,
      config,
      lib,
      pkgs,
      ...
    }:
    {
      imports = with my.modules.nixos.programs; [
        swayidle
        swaybg
        glitchpaper
        walker
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

        # auth agent. plasma-polkit-agent. Can be started with systemd.
        # pantheon.pantheon-agent-polkit
      ];

      # mako 1.11 does not read /etc/xdg on its own, so start it with an explicit
      # --config (the D-Bus activated instance gets no arguments).
      systemd.user.services.mako = {
        description = "Lightweight Wayland notification daemon";
        wantedBy = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        unitConfig.ConditionEnvironment = "WAYLAND_DISPLAY";
        restartTriggers = [ config.environment.etc."xdg/mako/config".source ];
        serviceConfig = {
          Type = "dbus";
          BusName = "org.freedesktop.Notifications";
          ExecStart = "${pkgs.mako}/bin/mako --config /etc/xdg/mako/config";
          ExecReload = "${pkgs.mako}/bin/makoctl reload";
        };
      };

      environment.etc."xdg/mako/config".text = ''
        # popups disappear on their own after 5s
        default-timeout=5000

        # Custom sound for Slack messages from Wesley Seubring whose body mentions gitlab.com.
        [app-name=Slack summary~="Wesley Seubring" body~="gitlab\.com"]
        on-notify=exec ${pkgs.pipewire}/bin/pw-play ${./sounds/not_another_one.mp3}
      '';

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

      # Start greetd immediately instead of waiting for systemd's boot job
      # queue to become idle, which leaves the console visible for ~5 seconds.
      systemd.services.greetd.serviceConfig.Type = lib.mkForce "simple";

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
