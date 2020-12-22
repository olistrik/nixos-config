{config, lib, pkgs, ...}:

with lib;

let
  cfge = config.environment;
  cfg = config.programs.sway;
in
  {
    imports = [
    ];

    options = {
      #programs.sway = {
      #  gaps = {
      #    inner = mkOption {
      #      type = types.int;
      #      default = 0;
      #      description = ''
      #        The gap in pixels between windows.
      #      '';
      #    };
      #    outer = mkOption {
      #      type = types.int;
      #      default = 0;
      #      description = ''
      #        The gap in pixels between the edges.
      #      '';
      #    };
      #  };
      #};
    };

    config = {
      #environment.etc."lightdm/background".source = pkgs.copyPathToStore /home/kranex/.lock_image;

      programs.sway = {
        enable = true;
        extraPackages = with pkgs; [
          swaylock
          swayidle
          xwayland
          waybar
          mako
          kanshi
        ];
      };

      environment = {
        etc = {
          "sway/config".source = ../../dots/i3.config;
        };
      };

      environment.systemPackages = with pkgs; [
        (pkgs.writeTextFile {
          name = "startsway";
          destination = "/bin/startsway";
          executable = true;
          text = ''
            #! ${pkgs.bash}/bin/bash

            # first import environment variables from the login manager
            systemctl --user import-environment
            # then start the service
            exec systemctl --user start sway.service
          '';
        })
      ];

      systemd.user.targets.sway-session = {
        description = "Sway compositor session";
        documentation = [ "man:systemd.special(7)" ];
        bindsTo = [ "graphical-session.target" ];
        wants = [ "graphical-session-pre.target" ];
        after = [ "graphical-session-pre.target" ];
      };

      systemd.user.services.sway = {
        description = "Sway - Wayland window manager";
        documentation = [ "man:sway(5)" ];
        bindsTo = [ "graphical-session.target" ];
        wants = [ "graphical-session-pre.target" ];
        after = [ "graphical-session-pre.target" ];
        # We explicitly unset PATH here, as we want it to be set by
        # systemctl --user import-environment in startsway
        environment.PATH = lib.mkForce null;
        serviceConfig = {
          Type = "simple";
          ExecStart = ''
            ${pkgs.dbus}/bin/dbus-run-session ${pkgs.sway}/bin/sway --debug
          '';
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
      };

      services.xserver = {

        desktopManager = {
          xterm.enable = false;
        };

        displayManager = {
          defaultSession = "none+i3";
          lightdm.greeters.mini = {
            enable = true;
            user = "kranex";
            extraConfig = ''
              [greeter]
              show-password-label = false
              [greeter-theme]
              background-color = "#303030"
              background-image = "/etc/lightdm/background.jpg"
              window-color ="#000000"
            '';
          };
        };
      };
    };
  }
