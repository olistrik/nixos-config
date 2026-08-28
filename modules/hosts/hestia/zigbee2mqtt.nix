{
  nixos.hosts.hestia =
    { pkgs, ... }:
    {
      networking.firewall.allowedTCPPorts = [
        80
        443
      ];

      olistrik.services.nixwarden.secrets = {
        "zigbee@mqtt.pass" = [
          {
            location = "/var/lib/mosquitto/zigbee@mqtt.pass";
            wantedBy = [ "mosquitto.service" ];
            userGroup = "mosquitto:mosquitto";
          }
        ];
        "zigbee2mqtt-secret.yaml" = [
          {
            location = "/var/lib/zigbee2mqtt/secret.yaml";
            wantedBy = [ "zigbee2mqtt.service" ];
            userGroup = "zigbee2mqtt:zigbee2mqtt";
          }
        ];
      };

      services = {
        mosquitto = {
          enable = true;
          listeners = [
            {
              acl = [ "pattern readwrite #" ];
              users.zigbee.passwordFile = "/var/lib/mosquitto/zigbee@mqtt.pass";
            }
          ];
        };

        zigbee2mqtt = {
          package = pkgs.zigbee2mqtt_2;
          enable = true;
          settings = {
            serial.port = "/dev/ttyUSB0";
            mqtt = {
              server = "mqtt://localhost:1883";
              user = "zigbee";
              password = "!secret.yaml password";
            };
            advanced.network_key = "!secret.yaml network_key";
            frontend = true;
          };
        };

        caddy.virtualHosts."zigbee.olii.nl".handler = ''
          reverse_proxy http://localhost:8080
        '';
      };
    };
}
