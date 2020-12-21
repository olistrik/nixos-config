{config, lib, pkgs, ...}:

with lib;

let
  cfge = config.environment;
  cfg = config.services.xserver.windowManager.i3;
in
  {
    imports = [
      ./picom.nix
    ];

    options = {
      services.xserver.windowManager.i3 = {
        gaps = {
          inner = mkOption {
            type = types.int;
            default = 0;
            description = ''
              The gap in pixels between windows.
            '';
          };
          outer = mkOption {
            type = types.int;
            default = 0;
            description = ''
              The gap in pixels between the edges.
            '';
          };
        };
      };
    };

    config.services.xserver = {
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
            background-image = "/home/kranex/.lock_image"
          '';
        };
      };

      windowManager.i3 = {
        enable = true;
        package = pkgs.i3-gaps;

        extraPackages = with pkgs; [
          rofi
          i3lock
          i3status
        ];

        configFile = (pkgs.writeText "i3-config" (''
            # Generated Config
            gaps inner ${builtins.toString cfg.gaps.inner}
            gaps outer ${builtins.toString cfg.gaps.outer}

            # User Config
          ''
          + (builtins.readFile ../../dots/i3.config))
        );
      };
    };
  }
