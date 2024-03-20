{ config, lib, pkgs, ... }:
with lib.olistrik;
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

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

  # NEVER CHANGE.
  system.stateVersion = "23.11";
}

