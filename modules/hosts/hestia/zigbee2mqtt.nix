{
  nixos.hosts.hestia =
    { pkgs, config, ... }:
    {
      networking.firewall.allowedTCPPorts = [
        80
        443
      ];

      # zigbee2mqtt and mosquitto are replaced by homewire's zigbee plugin (see homewire.nix).
      # Their state and secrets are kept for the way back: re-enable both and restore the
      # age.secrets below.
      environment.persistence."/persist".directories = [
        "/var/lib/mosquitto"
        "/var/lib/zigbee2mqtt"
      ];

      # Not declared while disabled: their owners only exist with the services enabled.
      # age.secrets = {
      #   "mosquitto-zigbee.pass" = {
      #     owner = "mosquitto";
      #   };
      #   "zigbee2mqtt-secret.yaml" = {
      #     owner = "zigbee2mqtt";
      #     path = "/var/lib/zigbee2mqtt/secret.yaml";
      #   };
      # };

      services = {
        mosquitto = {
          enable = false;
          listeners = [
            {
              acl = [ "pattern readwrite #" ];
              users.zigbee.passwordFile = config.age.secrets."mosquitto-zigbee.pass".path;
            }
          ];
        };

        zigbee2mqtt = {
          package = pkgs.zigbee2mqtt_2;
          enable = false;
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
      };
    };
}
