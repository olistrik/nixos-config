# Hestia is my home server responsible for managing all of my ZigBee and
# EspHome devices.

{
  nixos.hosts.hestia =
    { my, ... }:
    {
      imports = with my.modules.nixos; [
        collections.server

        services.nixwarden

        # ./build-all-systems.nix
        #
        # ./acme.nix
        # ./caddy.nix
        # # ./nginx.nix
        # ./tsidp.nix
        # ./postgres.nix
        # ./node-red.nix
        # ./immich.nix
        # ./nix-serve.nix
        # # ./palworld-server.nix
        # # ./valheim-server
        # ./nextcloud.nix
      ];

      # Enable Nixwarden
      olistrik.services.nixwarden = {
        accessTokenFile = "/var/lib/nixwarden/.nixwarden.key";
      };

      # NEVER CHANGE.
      networking.hostId = "1a75b647"; # Required for ZFS.
      system.stateVersion = "24.05"; # Did you read the comment?
    };
}
