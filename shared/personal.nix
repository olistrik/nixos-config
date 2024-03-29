# These are programs and their configs that I want on personal systems but are
# not needed on servers etc.
{ config, lib, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    # media
    spotify
    feh
    mplayer
    zathura

    # editing
    gimp

    # browsers
    google-chrome
  ];

  services.udev.extraRules = ''
        ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", MODE="664", GROUP="plugdev"
    	KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0664", GROUP="plugdev"
  '';
}
