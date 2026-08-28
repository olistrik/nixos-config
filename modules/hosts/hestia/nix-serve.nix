{
  nixos.hosts.hestia =
    { config, pkgs, ... }:
    let
      cfg = config.services.nix-serve;
      cacheInfoRoot = pkgs.writeTextDir "nix-cache-info" ''
        StoreDir: /nix/store
        WantMassQuery: 1
        Priority: 50
      '';
    in
    {
      age.secrets."nix-serve-key.pem" = {
        owner = "nix-serve";
      };

      # Enable nix-serve
      services.nix-serve = {
        enable = true;
        secretKeyFile = config.age.secrets."nix-serve-key.pem".path;
      };

      services.caddy.virtualHosts = {
        "cache.olii.nl".handler = ''

          route {
            @nixcache path /nix-cache-info
            root @nixcache ${cacheInfoRoot}
            header @nixcache Content-Type text/plain
            file_server @nixcache

            reverse_proxy http://${cfg.bindAddress}:${toString cfg.port} {
              flush_interval -1
            }
          }
        '';
      };
    };
}
