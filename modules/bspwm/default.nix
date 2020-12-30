# Some stuff

{config, lib, pkgs, ...}:

with lib;

let

  cfge = config.environment;

  cfg = config.programs.bspwm;

in

{
  options = {
    programs.bspwm = {
      enable = mkOption {
        default = false;
        description = ''
          enable or disable bspwm.
          '';
        type = types.bool;
      };
    };
  };

  config = mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      xterm
    ];

    # Enable the X11 windowing system.
    services.xserver.enable = true;
    services.xserver.layout = "us";
    services.xserver.xkbOptions = "eurosign:e";

    # Enable touchpad support.
    # services.xserver.libinput.enable = true;

    # Enable SDDM display manager.
    services.xserver.displayManager = {
      sddm.enable = true;
      defaultSession = "none+bspwm";
    };

    # Enable the BSPWM Window Manager.
    services.xserver.windowManager.bspwm.enable = true;
  };
}
