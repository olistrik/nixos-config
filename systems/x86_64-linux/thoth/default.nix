{ inputs, lib, ... }:
with lib;
with lib.olistrik;
{
  imports =
    [
      # Provided here for now. Later it'll be global.
      inputs.disko.nixosModules.default

      ./hardware-configuration.nix
      ./disko-configuration.nix
      ./persistence-configuration.nix
    ];

  # Shared configurations.
  olistrik = {
    collections = {
      personal = enabled;
      workstation = enabled;
    };

    wayland = {
      niri = enabled;
      ags = enabled;
    };
  };

  # Required for ZFS.
  networking.hostId = "8177229e";

  # Impermanence. Get rekt python.
  olistrik.impermanence.enable = true;
  users.mutableUsers = false;
  olistrik.user.hashedPasswordFile = "/persist/secret/user.password";
  olistrik.impermanence.zfs.snapshots = [ "zroot/local/root@blank" ];
  # When I'm ready for home impermanence, I'll add "zroot/local/home@blank"

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Enable wireless.
  hardware.bluetooth.enable = true;
  networking.networkmanager.enable = true;
  olistrik.user.extraGroups = [ "networkmanager" ];

  # Enable laptop powersaving features
  services.thermald.enable = true;
  services.tlp.enable = true;

  # NEVER CHANGE.
  system.stateVersion = "24.05"; # Did you read the comment?
}
