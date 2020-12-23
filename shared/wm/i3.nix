{config, lib, pkgs, ...}:

with lib;

let
  themer = config.system.themer;
  cfg = config.services.xserver.windowManager.i3;
in
  {
    imports = [
      ./picom.nix
    ];

    options = {
      services.xserver.windowManager.i3 = {
        locker = mkOption {
          type = types.str;
          default = "${pkgs.i3lock}/bin/i3lock -e -i ~/.lock_image";
        };
      };
    };

    config = {

      environment.etc."xdg/i3status/config".source = ../../dots/i3status.conf;

      xdg.autostart.enable = true;

      services.xserver = {
        enable = true;

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
        windowManager.i3 = {
          enable = true;
          package = pkgs.i3-gaps;

          extraPackages = with pkgs; [
            rofi
            polybar
            i3lock
            xautolock
            i3status
            i3blocks
          ];

          configFile = (
            pkgs.writeText "i3-config" (''
                ##########################
                # Generated Config
                gaps inner ${builtins.toString themer.wm.gaps.inner}
                gaps outer ${builtins.toString themer.wm.gaps.outer}

                exec --no-startup-id xautolock -time 5 -locker "${pkgs.lightdm}/bin/dm-tool lock" -nowlocker "${pkgs.lightdm}/bin/dm-tool lock"
                ##########################
                # User Config
              ''
              +
              (builtins.readFile ../../dots/i3.config)
            )
          );
        };
      };
    };
  }
