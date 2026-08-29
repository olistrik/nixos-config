{
  nixos.hosts.hestia =
    { config, ... }:
    {
      services.immich = {
        enable = true;
      };

      # TODO: assumes caddy? not that big of a deal though.
      services.caddy.virtualHosts = {
        "immich.olii.nl".handler = with config.services.immich; ''
          reverse_proxy http://${host}:${toString port}
        '';
      };
    };
}
