# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ lib, ... }:
with lib.olistrik;
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./home-assistant.nix
    ./home-control.nix
    ./palworld.nix
    ./acme.nix
  ];

  networking.hostName = "hestia";

  olistrik.collections.server = enabled;

  # Enable Nixwarden
  olistrik.services.nixwarden = {
    accessTokenFile = "/nixos/.nixwarden.key";
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Select internationalisation properties.
  time.timeZone = "Europe/Amsterdam";
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  system.stateVersion = "22.11";
}
