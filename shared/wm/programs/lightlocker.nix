{ config, lib, pkgs, ... }:

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
      (pkgs.makeAutostartItem {
        name = "light-locker";
        package = lightlocker;
      })
    ];
  };
}
