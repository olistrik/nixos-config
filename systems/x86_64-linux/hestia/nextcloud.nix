{ lib, config, pkgs, ... }:
let
  cfg = config.services.nextcloud;
in
{
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud32;
    hostName = "cloud.olii.nl";
    https = true;
    database.createLocally = true;
    config = {
      dbtype = "pgsql";

      # Using socket auth.
      adminuser = null;
      adminpassFile = null;

    };
    settings = {
      # social_login_auto_redirect = true;
    };
    extraApps = {
      inherit (cfg.package.packages.apps) calendar contacts tasks mail sociallogin;
    };
  };

  # WARN: REMOVE IN 25.11
  systemd.services.nextcloud-setup = {
    after = lib.mkForce [ "postgresql.service" ];
    requires = lib.mkForce [ "postgresql.service" ];
  };

  users.groups.nextcloud.members = lib.mkForce [ "nextcloud" ];
  services.nginx.enable = lib.mkOverride 999 false;
  services.phpfpm.pools.nextcloud.settings."listen.owner" = config.services.caddy.user;
  services.phpfpm.pools.nextcloud.settings."listen.group" = config.services.caddy.group;

  services.caddy.virtualHosts = {
    ${cfg.hostName}.extraConfig = ''
      header {
          Strict-Transport-Security max-age=31536000;
      }

      redir /.well-known/carddav   /remote.php/dav 301
      redir /.well-known/caldav    /remote.php/dav 301
      redir /.well-known/webfinger /index.php/.well-known/webfinger
      redir /.well-known/nodeinfo  /index.php/.well-known/nodeinfo

      root * ${cfg.finalPackage}

      @davClnt {
        header_regexp User-Agent ^DavClnt
        path /
      }

      redir @davClnt /remote.php/webdev{uri} 302


      @sensitive {
        # ^/(?:build|tests|config|lib|3rdparty|templates|data)(?:$|/)
        path /build     /build/*
        path /tests     /tests/*
        path /config    /config/*
        path /lib       /lib/*
        path /3rdparty  /3rdparty/*
        path /templates /templates/*
        path /data      /data/*

        # ^/(?:\.|autotest|occ|issue|indie|db_|console)
        path /.*
        path /autotest*
        path /occ*
        path /issue*
        path /indie*
        path /db_*
        path /console*
      }
      respond @sensitive 404

      php_fastcgi unix/${config.services.phpfpm.pools.nextcloud.socket} {
        env front_controller_active true
      }
      file_server
    '';
  };

  # services.nginx.virtualHosts.${cfg.hostName} = {
  #   forceSSL = true;
  #   useACMEHost = "olii.nl";
  #   # secured with oauth2 (probably?);
  #   tailscaleForwardAuth.enable = false;
  # };
}








