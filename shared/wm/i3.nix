{config, lib, pkgs, ...}:

with lib;

let
  themer = config.system.themer;
  cfg = config.services.xserver.windowManager.i3;
in
  {
    imports = [
      ./picom.nix
      ../scripts/chuckjoke.nix
    ];

    options = {
      services.xserver.windowManager.i3 = {
        locker = mkOption {
          type = types.str;
          default = ''${pkgs.i3lock}/bin/i3lock-fancy --no-fork -t '$( ${pkgs.wget}/bin/wget http://api.icndb.com/jokes/random -qO- | jshon -e value -e joke -u | fold -s)' -f 'JetBrains-Mono-Regular-Nerd-Font-Complete' '';
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

        xautolock = {
          enable = true;
          time = 5;
          locker = "${pkgs.i3lock-fancy}/bin/i3lock-fancy --nofork -t '$(${pkgs.chucknorris}/bin/chucknorris)' -f 'JetBrains-Mono-Regular-Nerd-Font-Complete'";
          nowlocker = "${pkgs.i3lock-fancy}/bin/i3lock-fancy --nofork -t '$(${pkgs.chucknorris}/bin/chucknorris)' -f 'JetBrains-Mono-Regular-Nerd-Font-Complete'";
          #default = ''${pkgs.i3lock}/bin/i3lock-fancy --no-fork -t '$( ${pkgs.wget}/bin/wget http://api.icndb.com/jokes/random -qO- | jshon -e value -e joke -u | fold -s)' -f 'JetBrains-Mono-Regular-Nerd-Font-Complete' '';
        };

        windowManager.i3 = {
          enable = true;
          package = pkgs.i3-gaps;

          extraPackages = with pkgs; [
            rofi
            polybar
            i3lock-fancy
            i3status
            i3blocks
          ];

          configFile = (
            pkgs.writeText "i3-config" (''
                ##########################
                # Generated Config
                gaps inner ${builtins.toString themer.wm.gaps.inner}
                gaps outer ${builtins.toString themer.wm.gaps.outer}

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
