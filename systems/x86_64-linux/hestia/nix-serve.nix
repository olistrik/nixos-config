{ config, pkgs, ... }:
let
  cfg = config.services.nix-serve;
in
{
  # Enable nix-serve
  services.nix-serve = {
    enable = true;
    # default doesn't support priority.
    package = pkgs.nix-serve-ng;
    # maybe this needs to go in nixwarden?
    secretKeyFile = "/var/lib/nix-serve/cache-priv-key.pem";
    # prefer cache.nixos.org; This is for custom and overridden packages, not a forward cache.
    extraParams = "--priority 50";
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    virtualHosts = {
      "cache.olii.nl" = {
        forceSSL = true;
        useACMEHost = "olii.nl";
        locations = {
          "/" = {
            proxyPass = "http://${cfg.bindAddress}:${toString cfg.port}";
            proxyWebsockets = true;
          };
        };
      };
    };
  };
}
