{config, pkgs, ...}:

{
  environment.systemPackages = with pkgs; [
    polybar
    dmenu
    sxhkd
    picom
  ];

  ## Enable X + SDDM + BSPWM.
  services.xserver = {
    enable = true;
    layout = "us";
    xkbOptions = "eurosign:5";

    displayManager = {
      sddm.enable = true;
      defaultSession = "none+bspwm";
    };

    windowManager.bspwm = {
      enable = true;
    };
  };
}
