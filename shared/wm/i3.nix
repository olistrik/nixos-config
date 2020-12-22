{config, lib, pkgs, ...}:

with lib;

let
  cfg = config.system.themer;
in
  {
    imports = [
      ./picom.nix
    ];

    #environment.etc."lightdm/background".source = pkgs.copyPathToStore /home/kranex/.lock_image;

    environment.etc."i3/xdg/i3status/config".source = ../../dots/i3status.conf;

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
          i3lock
          i3status
          i3blocks
        ];

        configFile = (pkgs.writeText "i3-config" (''
            # Generated Config
            gaps inner ${builtins.toString cfg.wm.gaps.inner}
            gaps outer ${builtins.toString cfg.wm.gaps.outer}

            # User Config
          ''
          + (builtins.readFile ../../dots/i3.config))
        );
      };
    };
  }
