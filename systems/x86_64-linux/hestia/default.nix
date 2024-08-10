# Hestia is my home server responsible for managing all of my ZigBee and
# EspHome devices.

{ lib, ... }:
with lib.olistrik;
{
  imports = [
    ./hardware-configuration.nix
    ./disko-configuration.nix
    ./persistence-configuration.nix

    ./acme.nix
    ./node-red.nix
    # ./palworld-server.nix
    # ./valheim-server
  ];

  # Shared configurations.
  olistrik.collections = {
    common = enabled;
    server = enabled;
  };

  # Required for ZFS.
  networking.hostId = "1a75b647";

  # Impermanence. Get rekt python.
  olistrik.impermanence.enable = true;
  users.mutableUsers = false;
  olistrik.user.hashedPasswordFile = "/persist/secret/user.password";
  olistrik.impermanence.zfs.snapshots = [ "zroot/local/root@blank" ];

  # Enable Nixwarden
  olistrik.services.nixwarden = {
    accessTokenFile = "/var/lib/nixwarden/.nixwarden.key";
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # NEVER CHANGE.
  system.stateVersion = "24.05"; # Did you read the comment?
}

