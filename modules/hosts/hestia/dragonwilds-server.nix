{
  nixos.hosts.hestia =
    { my, config, ... }:
    {
      imports = with my.modules.nixos; [
        services.dragonwilds-server
      ];

      age.secrets."dragonwilds-server.env" = { };

      environment.persistence."/persist".directories = [
        {
          directory = "/var/lib/dragonwilds-server";
          # Matches the uid/gid baked into the image's "steam" user.
          user = "1000";
          group = "1000";
          mode = "0750";
        }
      ];

      services.dragonwilds-server = {
        openFirewall = true;
        environmentFiles = [ config.age.secrets."dragonwilds-server.env".path ];

        # Fixed so the container doesn't pick a new random world name on every restart.
        worldName = "Hestia";

        # secrets/dragonwilds-server.env.age must at least set:
        #   RSDW_OWNER_ID=<your player ID, found in-game at the bottom of Settings>
        # and may optionally set RSDW_PASSWORD, RSDW_ADMIN_PASSWORD and RSDW_ADMINS.
      };
    };
}
