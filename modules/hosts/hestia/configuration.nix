# Hestia is my home server responsible for managing all of my ZigBee and
# EspHome devices.

{
  nixos.hosts.hestia =
    { my, ... }:
    {
      imports = with my.modules.nixos; [
        collections.server
        system.agenix
        system.impermanence
      ];

      # Enable Hindsight API
      services.hindsight = {
        # enable = true;
      };

      age.identityPaths = [ "/persist/age/hestia-identity" ];

      # Deliberately not "weekly" (Monday 00:00): that collides with the
      # build-all-systems timer, and running both against the store at once
      # can GC a source path npins just fetched mid-evaluation.
      nix.gc = {
        automatic = true;
        dates = "Thu 03:00";
        options = "--delete-older-than 30d";
      };

      # NEVER CHANGE.
      networking.hostId = "1a75b647"; # Required for ZFS.
      system.stateVersion = "24.05"; # Did you read the comment?
    };
}
