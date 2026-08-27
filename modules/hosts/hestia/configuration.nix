# Hestia is my home server responsible for managing all of my ZigBee and
# EspHome devices.

{
  nixos.hosts.hestia =
    { my, ... }:
    {
      imports = with my.modules.nixos; [
        collections.server
        services.nixwarden
      ];

      # Enable Hindsight API
      services.hindsight = {
        # enable = true;
      };

      # Enable Nixwarden
      olistrik.services.nixwarden = {
        accessTokenFile = "/var/lib/nixwarden/.nixwarden.key";
      };

      # NEVER CHANGE.
      networking.hostId = "1a75b647"; # Required for ZFS.
      system.stateVersion = "24.05"; # Did you read the comment?
    };
}
