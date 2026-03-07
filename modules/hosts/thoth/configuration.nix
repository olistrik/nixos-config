# Thoth is my personal laptop as it is used primarily for university work and
# provisioning my other nixos hosts.
{
  nixos.hosts.thoth =
    { self, ... }:
    {
      imports = with self.modules.nixos; [
        ./_hardware-configuration.nix

        # I don't really _like_ this; but I don't want to make disko into a module.
        (self.sources.disko + "/module.nix")
        ./_disko-configuration.nix

        # double imports work fine; they're deduped by the keys as expected.
        containers.docker
        containers.docker
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
    };
}
