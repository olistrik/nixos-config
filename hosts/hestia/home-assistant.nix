{ pkgs, ... }: {
  services.home-assistant = {
    enable = true;
    extraComponents = [ 
    "default_config" 
    "met"
    "esphome"
    "piper"
    "whisper"
    "wake_word"
    "wyoming"
	"wiz"
	"hue"
	"zha"
  ];
  extraPackages = py: with py; with pkgs.unstable; [ 
	# postgres
    psycopg2
  ];
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
      wake_word = {};
	  automation = "!include automations.yaml";
	  esphome = {};
    };
  };

  services.wyoming = {
    piper = {
      servers.hestia = {
        voice = "en_GB-southern_english_female-low";
        uri = "tcp://0.0.0.0:10200";
      };
    };

    faster-whisper = {
      servers.hestia = {
        model = "tiny-int8";
        uri = "tcp://0.0.0.0:10300";
        device = "cpu"; # I need my 1060 back >.<
        beamSize = 1;
        language = "en";
      };
    };

    openwakeword = {
      enable = true;
      uri = "tcp://0.0.0.0:10400";
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
	  ensureDBOwnership = true;
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
