{ config, ... }: {

  services.immich = {
    enable = true;
    openFirewall = true;
  };

  services.caddy.virtualHosts = {
    "immich.olii.nl".extraConfig = with config.services.immich; ''
      reverse_proxy http://${host}:${toString port}
    '';
  };
}



