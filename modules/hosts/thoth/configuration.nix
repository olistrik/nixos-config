# Thoth is my personal laptop as it is used primarily for university work and
# provisioning my other nixos hosts.

{ self, ... }:
{
  imports = [
    ./hardware-configuration.nix

    (self.sources.disko + "/module.nix")
    ./disko-configuration.nix

    (self.sources.impermanence + "/nixos.nix")
    ./impermanence.nix
  ];

  nixpkgs.config = {
    allowUnfree = true;
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Documentation.
  documentation.nixos.enable = false;

  # NEVER CHANGE.
  networking.hostId = "8177229e"; # Required for ZFS.
  system.stateVersion = "24.05"; # Did you read the comment?
}
