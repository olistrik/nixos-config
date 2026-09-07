{
  nixos.hosts.hestia =
    { config, pkgs, my, ... }:
    let
      unstable = import my.sources.unstable { inherit (pkgs) system; config.allowUnfree = true; };
    in
    {
      services.immich = {
        enable = true;
        package = unstable.immich;
      };

      # TODO: assumes caddy? not that big of a deal though.
      services.caddy.virtualHosts = {
        "immich.olii.nl".handler = with config.services.immich; ''
          reverse_proxy http://${host}:${toString port}
        '';
      };
    };
}
