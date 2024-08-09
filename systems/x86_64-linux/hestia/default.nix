{ config, lib, pkgs, inputs, ... }:
with lib.olistrik;
{
  imports =
    [
      # Provided here for now. Later it'll be global.
      inputs.disko.nixosModules.default

      ./hardware-configuration.nix
      ./disko-configuration.nix
      ./persistence-configuration.nix

      # ./acme.nix
      # ./node-red.nix
      # ./palworld-server.nix
      # ./valheim-server
    ];

  # Required for ZFS.
  networking.hostId = "1a75b647";

  olistrik.collections = {
    common = enabled;
    # server = enabled;
  };

  # Enable Nixwarden
  olistrik.services.nixwarden = {
    # accessTokenFile = "/var/lib/nixwarden/.nixwarden.key";
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot = enabled;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Select internationalisation properties.
  time.timeZone = "Europe/Amsterdam";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # NEVER CHANGE.
  system.stateVersion = "24.05"; # Did you read the comment?
}

