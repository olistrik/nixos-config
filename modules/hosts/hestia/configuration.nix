# Hestia is my home server responsible for managing all of my ZigBee and
# EspHome devices.

{
  nixos.hosts.hestia =
    { my, ... }:
    {
      imports = with my.modules.nixos; [
        collections.server
        system.agenix
      ];

      # Enable Hindsight API
      services.hindsight = {
        # enable = true;
      };

      age.identityPaths = [ "/persist/age/hestia-identity" ];

      nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };

      # NEVER CHANGE.
      networking.hostId = "1a75b647"; # Required for ZFS.
      system.stateVersion = "24.05"; # Did you read the comment?
    };
}
