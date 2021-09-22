# These are programs and their configs that I want on personal systems but are
# not needed on servers etc.
{ config, lib, pkgs, ... }:
{
  imports = [
    ./programs/alacritty.nix
  ];

  # disable mouse acceleration
  services.xserver.libinput = {
    enable = true;
    mouse = {
      accelProfile = "flat";
    };
  };

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

    # keyboard
    unstable.qmk
    gcc-arm-embedded
    dfu-util
  ];
}
