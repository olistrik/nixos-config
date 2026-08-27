{
  nixos.hosts.hestia =
    { ... }:
    let
      homewireSrc = builtins.fetchGit {
        url = "git@github.com:olistrik/homewire.git";
        ref = "master";
      };
    in
    {
      imports = [
        (import homewireSrc { }).nixosModule
      ];

      services.caddy.virtualHosts = {
        "wire.olii.nl".handler = ''
          reverse_proxy http://localhost:5173
        '';
      };

      services.avahi = {
        enable = true;
        openFirewall = true;
      };

      services.homewire = {
        # enable = true;

        # Optional bridges
        zigbee2mqtt.enable = true;
        #   reads MQTT_USERNAME / MQTT_PASSWORD from environmentFile
        #   (defaults to dataDir/.env when zigbee2mqtt is enabled)

        esphome.enable = true;
        esphome.discover = true;

        studio.enable = true;
        studio.port = 3030;

        functionalNodes.enable = true; # default: true
        syntheticNodes.enable = false; # default: false

        extraConfig = ''
          hw.setTypeEventMap("zigbee2mqtt/Philips/929002398602", {
          	on_press: "onoff.toggle",
          	off_press: "onoff.off",
          	up_press: "brightness.step_up",
          	up_hold: "brightness.move_up",
          	up_hold_release: "brightness.stop",
          	down_press: "brightness.step_down",
          	down_hold: "brightness.move_down",
          	down_hold_release: "brightness.stop",
          });

          hw.setTypeEventMap("zigbee2mqtt/Philips/8719514440937_8719514440999", {
          	// button_1_press: "1.onoff.toggle",
          	button_1_press_release: "1.onoff.toggle",
          	button_1_hold: "1.brightness.move_up",
          	button_1_hold_release: "1.brightness.stop",
          	// button_2_press: "2.onoff.toggle",
          	button_2_press_release: "2.onoff.toggle",
          	button_2_hold: "2.brightness.move_up",
          	button_2_hold_release: "2.brightness.stop",
          	// button_3_press: "3.onoff.toggle",
          	button_3_press_release: "3.onoff.toggle",
          	button_3_hold: "3.brightness.move_down",
          	button_3_hold_release: "3.brightness.stop",
          	// button_4_press: "4.onoff.toggle",
          	button_4_press_release: "4.onoff.toggle",
          	button_4_hold: "4.brightness.move_down",
          	button_4_hold_release: "4.brightness.stop",
          });

          hw.setTypeEventMap("zigbee2mqtt/Philips/9290030675", {
          	"occupancy.occupied": "onoff.on",
          	"occupancy.unoccupied": "onoff.off",
          });
        '';
      };
    };
}
