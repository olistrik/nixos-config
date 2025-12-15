{ config, ... }:
let
  cfg = config.services.nix-serve;
  priority = 50;
in
{
  # Enable nix-serve
  services.nix-serve = {
    enable = true;
    # maybe this needs to go in nixwarden?
    secretKeyFile = "/var/lib/nix-serve/cache-priv-key.pem";
  };

  services.caddy.virtualHosts =
    {
      "cache.olii.nl".extraConfig = ''
        # Serve /nix-cache-info with the fixed response
        @nixcache path /nix-cache-info
        respond @nixcache "StoreDir: /nix/store\nWantMassQuery: 1\nPriority: ${toString priority}\n" 200

        # Proxy everything else to your service
        route {
        	reverse_proxy http://${cfg.bindAddress}:${toString cfg.port} {
        		flush_interval -1
        	}
        }
      '';
    };

  services.nginx = {
    recommendedProxySettings = true;
    virtualHosts = {
      "cache.olii.nl" = {
        forceSSL = true;
        useACMEHost = "olii.nl";
        locations = {
          "/nix-cache-info" = {
            return = ''200 "StoreDir: /nix/store\nWantMassQuery: 1\nPriority: ${toString priority}\n"'';
          };
          "/" = {
            proxyPass = "http://${cfg.bindAddress}:${toString cfg.port}";
            proxyWebsockets = true;
          };
        };
      };
    };
  };
}
