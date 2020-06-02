{config, pkgs, ...}:

{

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "eurosign:e";
  

  # Enable touchpad support.
  # services.xserver.libinput.enable = true;

  # Enable SDDM display manager.
  services.xserver.displayManager.sddm.enable = true;

  # Enable the BSPWM Window Manager.
  services.xserver.windowManager.bspwm.enable = true;
  services.xserver.desktopManager.xterm.enable = true; #temp until we get default bspwm config.

}
