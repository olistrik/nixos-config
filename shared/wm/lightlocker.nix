{config, lib, pkgs, ...}:

let
  cfg = config.programs.lightlocker;
in
  with lib; {
    options = {
      programs.lightlocker = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = ''
            enable or disable light-locker.
          '';
        };
        lock-after-screensaver = mkOption {
          type = types.int;
          default = 0;
          description = ''
            Lock the screen S seconds after the screensaver started. Use 0 to
            disable.
          '';
        };
        late-locking = mkOption {
          type = types.bool;
          default = true;
          description = ''
            Lock the screen after screensaver deactivation.
          '';
        };
        lock-on-suspend = mkOption {
          type = types.bool;
          default = true;
          description = ''
            Lock the screen on suspend.
          '';
        };
        lock-on-lid = mkOption {
          type = types.bool;
          default = true;
          description = ''
            Lock the screen on lid close.
          '';
        };
        idle-hint = mkOption {
          type = types.bool;
          default = true;
          description = ''
            Set the session idle hint while the
            screensaver is active.
          '';
        };
      };
    };

    config = mkIf cfg.enable {
      environment.systemPackages = with pkgs; [
        lightlocker
      ];
      systemd.services.lightlocker = {
        wantedBy = [ "graphical-session.target" ];
        after = ["graphical-session.target"];
        description = "Start lightlocker";
        serviceConfig = {
          Type = "exec";
          ExecStart = '' ${pkgs.lightlocker}/bin/light-locker \
            --lock-after-screensaver=${toString cfg.lock-after-screensaver} \
            --${if cfg.late-locking then "" else "no-"}late-locking \
            --${if cfg.lock-on-suspend then "" else "no-"}lock-on-suspend \
            --${if cfg.lock-on-lid then "" else "no-"}lock-on-lid \
            --${if cfg.idle-hint then "" else "no-"}idle-hint
          '';
        };
      };
    };
  }
