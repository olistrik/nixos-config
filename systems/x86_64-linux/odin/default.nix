# Odin was previously Hestia (Not canon mythology) but was renamed for
# migration to a less power hungry PC.
#
# I don't yet know if Hestia will be powerful enough to host a valheim server
# so I may need setup Odin again one day.

{ lib, ... }:
with lib.olistrik;
{
  assertions = [{
    assertion = false;
    message = "Odin is not fully configured.";
  }];

  imports = [ ./hardware-configuration.nix ];

  olistrik.collections.server = enabled;

  # Enable Nixwarden
  olistrik.services.nixwarden = {
    accessTokenFile = "/var/lib/nixwarden/.nixwarden.key";
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";


  # Enable the GPU so that it will actually go to sleep.
  hardware.opengl.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    nvidiaSettings = true;
    open = false;
  };

  # NEVER CHANGE.
  system.stateVersion = "23.11";
}

