{ pkgs, ... }: {

  services.home-assistant = {
    enable = true;
    extraComponents = [ "default_config" ];
    extraPackages = py: with py; [ psycopg2 ];
    config = {
      default_config = { };
      recorder = { db_url = "postgresql://@/hass"; };
      http = {
        server_host = "::1";
        trusted_proxies = [ "::1" ];
        use_x_forwarded_for = true;
      };
      homeassistant = {
        name = "Hestia";
        latitude = "!secret longitude";
        longitude = "!secret latitude";
        temperature_unit = "C";
        unit_system = "metric";
        time_zone = "Europe/Amsterdam";
      };
    };
  };

  services.nixwarden = {
    secrets = {
      "home-assistant.secrets.yaml" = {
        location = "/var/lib/hass/secrets.yaml";
        wantedBy = [ "home-assistant.service" ];
        userGroup = "hass:hass";
      };
    };
  };

  services.postgresql = {
    enable = true;

    ensureDatabases = [ "hass" ];
    ensureUsers = [{
      name = "hass";
      ensurePermissions = { "DATABASE hass" = "ALL PRIVILEGES"; };
    }];
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    virtualHosts."home.olii.fans" = {
      # forceSSL = true;
      # enableACME = true;
      extraConfig = ''
        proxy_buffering off;
      '';
      locations."/" = {
        proxyPass = "http://[::1]:8123";
        proxyWebsockets = true;
      };
    };
  };
}
