{ ... }: {

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
        extraConfig = ''
          proxy_buffering off;
          client_max_body_size 0;
        '';
        locations = {
          "/" = {
            proxyPass = "http://localhost:3001";
            proxyWebsockets = true;
          };
        };
      };
    };
  };
}
