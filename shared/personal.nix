# These are programs and their configs that I want on personal systems but are
# not needed on servers etc.
{ config, lib, pkgs, ... }:
{
  imports = [
    ./programs/alacritty.nix
    ./wm/i3.nix
  ];

  # disable mouse acceleration
  services.xserver.libinput.enable = true;
  services.xserver.config = ''
    Section "InputClass"
      Identifier "mouse accel"
      Driver "libinput"
      MatchIsPointer "on"
      Option "AccelProfile" "flat"
      Option "AccelSpeed" "0"
    EndSection
  '';

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
}
