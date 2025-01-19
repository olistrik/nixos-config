# These are programs and their configs that I want on personal systems but are
# not needed on servers etc.
{ lib, config, pkgs, ... }:
with lib;
with lib.olistrik;
let
  cfg = config.olistrik.collections.personal;
in
{
  options.olistrik.collections.personal = with types; {
    enable = mkEnableOption "personal configuration";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs;
      [
        # media
        spotify
        feh
        mplayer
        zathura
        discord

        # editing
        gimp
        inkscape
        obsidian

        # browsers
        google-chrome
      ];

    services.udev.extraRules = ''
      ACTION="add", SUBSYSTEM=="usb", ATTR{idVendor}=="2886", ATTR{idProduct}=="0062", MODE="0666", GROUP="plugdev"
    '';

    # TODO: add this to some keyboard module
    # services.udev.extraRules = ''
    #       ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", MODE="664", GROUP="plugdev"
    #   	KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0664", GROUP="plugdev"
    # '';
  };
}
