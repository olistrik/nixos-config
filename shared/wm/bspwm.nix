{ config, pkgs, ... }:

{

  imports = [ ./programs/picom.nix ];

  environment.systemPackages = with pkgs; [ polybar dmenu sxhkd ];

  ## Enable X + SDDM + BSPWM.
  services.xserver = {
    enable = true;

    desktopManager = { xterm.enable = false; };

    displayManager = {
      defaultSession = "none+bspwm";
      lightdm.greeters.mini = {
        enable = true;
        user = "oli";
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

    windowManager.bspwm = { enable = true; };
  };
}
