{ lib, config, pkgs, ... }:
let
  cfg = config.services.nextcloud;
in
{
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud32;
    hostName = "cloud.olii.nl";
    database.createLocally = true;

    config = {
      dbtype = "pgsql";

      # Using socket auth.
      adminuser = null;
      adminpassFile = null;
    };

    extraApps = {
      inherit (cfg.package.packages.apps) calendar contacts tasks mail user_saml;
    };
  };

  # WARN: REMOVE IN 25.11
  systemd.services.nextcloud-setup = {
    after = lib.mkForce [ "postgresql.service" ];
    requires = lib.mkForce [ "postgresql.service" ];
  };

  services.nginx.virtualHosts.${cfg.hostName} = {
    forceSSL = true;
    useACMEHost = "olii.nl";
    tailscaleForwardAuth = {
      requiresCapability = "${cfg.hostName}/cap/auth";
    };
  };
}








