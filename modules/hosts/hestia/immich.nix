{
  nixos.hosts.hestia =
    { config, ... }:
    {
      services.immich = {
        enable = true;
        openFirewall = true;
      };

      # TODO: assumes caddy? not that big of a deal though.
      services.caddy.virtualHosts = {
        "immich.olii.nl".extraConfig = with config.services.immich; ''
          reverse_proxy http://${host}:${toString port}
        '';
      };
    };
}
