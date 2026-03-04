# Thoth is my personal laptop as it is used primarily for university work and
# provisioning my other nixos hosts.
{ config, ... }:
{
  modules.nixos.thoth =
    { pkgs, ... }:
    {
      imports = with config.modules.enable; [
        # docker
      ];

      foo = true; # Works with or without docker.
      virtualisation.docker.enable = false; # Fails with docker.

      # Bootloader
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
      boot.loader.efi.efiSysMountPoint = "/boot/efi";

      # NEVER CHANGE.
      networking.hostId = "8177229e"; # Required for ZFS.
      system.stateVersion = "24.05"; # Did you read the comment?
    };
}
