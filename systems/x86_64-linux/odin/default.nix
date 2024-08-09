{ config, lib, pkgs, ... }:
with lib.olistrik;
{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./acme.nix
      ./node-red.nix
      # ./palworld-server.nix

      # ./valheim-server
    ];

  olistrik.collections.server = enabled;

  # Enable Nixwarden
  olistrik.services.nixwarden = {
    accessTokenFile = "/var/lib/nixwarden/.nixwarden.key";
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/efi";

  # Select internationalisation properties.
  time.timeZone = "Europe/Amsterdam";
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  hardware.opengl = {
    enable = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    nvidiaSettings = true;
    open = false;
  };

  # NEVER CHANGE.
  system.stateVersion = "23.11";
}

