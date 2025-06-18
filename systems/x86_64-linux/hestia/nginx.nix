{ ... }:
{
  services.nginx = {
    enable = true;

    # Require tailscaleAuth for all virtual hosts.
    tailscaleForwardAuth = {
      enable = true;
      requiresCapability = "olii.nl/cap/auth";
    };

    # General virtual hosts that are not specific to a service.
    virtualHosts = {
      # Private redirect for microtik portals.
      "router.olii.nl" = {
        forceSSL = true;
        useACMEHost = "olii.nl";
        locations = {
          "/" = {
            proxyPass = "http://192.168.88.1";
            recommendedProxySettings = true;
          };
        };
      };

      # Loki's NextJS dev server. 
      "loki.olii.nl" = {
        forceSSL = true;
        useACMEHost = "olii.nl";
        tailscaleForwardAuth = {
          requiresCapability = "loki.olii.nl/cap/auth";
        };
        locations = {
          "/" = {
            proxyPass = "http://100.97.72.67:3000";
            recommendedProxySettings = true;
            proxyWebsockets = true;
            extraConfig = ''
              proxy_buffering off;
              proxy_request_buffering off;
            '';
          };
        };
      };

      # Loki's RabbitMQ management interface.
      "rmq.olii.nl" = {
        forceSSL = true;
        useACMEHost = "olii.nl";
        locations = {
          "/" = {
            proxyPass = "http://100.97.72.67:15672/";
            recommendedProxySettings = true;
            proxyWebsockets = true;
          };
        };
      };
    };
  };

}
