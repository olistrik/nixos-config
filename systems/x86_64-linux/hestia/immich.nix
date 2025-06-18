{ config, ... }: {

  services.immich = {
    enable = true;
    openFirewall = true;
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    virtualHosts = {
      "immich.olii.nl" = {
        forceSSL = true;
        useACMEHost = "olii.nl";
        tailscaleForwardAuth = {
          requiresCapability = "immich.olii.nl/cap/auth";
        };
        extraConfig = ''
          proxy_buffering off;
          client_max_body_size 0;
        '';
        locations = {
          "/" = {
            proxyPass = with config.services.immich; "http://${host}:${toString port}";
            proxyWebsockets = true;
          };
        };
      };
    };
  };
}
