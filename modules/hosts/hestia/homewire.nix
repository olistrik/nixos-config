{
  nixos.hosts.hestia =
    {
      my,
      config,
      ...
    }:
    {
      imports = [ my.projects.homewire.nixosModules.default ];

      environment.persistence."/persist".directories = [
        # the kernel's live layer and accounts.
        {
          directory = "/var/lib/homewired";
          user = "homewire";
          group = "homewire";
          mode = "0750";
        }
        # the zigbee network, imported from zigbee2mqtt.
        {
          directory = "/var/lib/homewire-zigbee";
          user = "homewire";
          group = "homewire";
          mode = "0750";
        }
        # the old TypeScript homewire's graph, kept for the way back.
        "/var/lib/homewire"
      ];

      # Unused since the cutover; kept for the way back.
      age.secrets."homewire.env" = {
        owner = "homewire";
      };

      age.secrets."homewire-zigbee-token" = {
        owner = "homewire";
      };
      age.secrets."homewire-esphome-token" = {
        owner = "homewire";
      };

      services.caddy.virtualHosts."wire.olii.nl".handler = ''
        reverse_proxy http://127.0.0.1:8480 {
          header_up Tailscale-User-Login {http.auth.user.id}
          header_up Tailscale-App-Capabilities {tailscale.grants}
        }
      '';

      # The ESPHome plugin discovers the air conditioners over mDNS.
      services.avahi = {
        enable = true;
        openFirewall = true;
      };

      services.homewire = {
        enable = true;
        timezone = "Europe/Amsterdam";
        dataDir = "/var/lib/homewired";
        documentFile = ./house.json5;

        nodeTypes.functional.component = "${my.projects.homewire.packages.homewire-functional}/functional.wasm";

        plugins.zigbee = {
          enable = true;
          tokenFile = config.age.secrets."homewire-zigbee-token".path;
          serialPort = "/dev/serial/by-id/usb-Nabu_Casa_SkyConnect_v1.0_766219157fb7ed119a4a995938a92db5-if00-port0";
          adapter = "ember";
          # The live network's channel (coordinator_backup.json); the module default is 25.
          channel = 11;
          dataDir = "/var/lib/homewire-zigbee";
        };

        plugins.esphome = {
          enable = true;
          tokenFile = config.age.secrets."homewire-esphome-token".path;
        };

        access = {
          roles.household = [
            "view"
            "control"
          ];
          network = [
            {
              from = "192.168.10.0/24";
              role = "household";
            }
          ];
          proxy = {
            from = [
              "127.0.0.1"
              "::1"
            ];
            user_header = "tailscale-user-login";
            groups_header = {
              name = "tailscale-app-capabilities";
              json = "$['wire.olii.nl/cap/homewire'][*].groups[*]";
            };
          };
          groups = {
            owner = [ "owner" ];
            household = [ "household" ];
          };
        };
      };
    };
}
