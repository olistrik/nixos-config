{
  nixos.hosts.hestia =
    { pkgs, config, ... }:
    {
      networking.firewall.allowedTCPPorts = [
        80
        443
      ];

      age.secrets = {
        "mosquitto-zigbee.pass" = {
          owner = "mosquitto";
        };
        "zigbee2mqtt-secret.yaml" = {
          owner = "zigbee2mqtt";
          path = "/var/lib/zigbee2mqtt/secret.yaml";
        };
      };

      services = {
        mosquitto = {
          enable = true;
          listeners = [
            {
              acl = [ "pattern readwrite #" ];
              users.zigbee.passwordFile = config.age.secrets."mosquitto-zigbee.pass".path;
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
