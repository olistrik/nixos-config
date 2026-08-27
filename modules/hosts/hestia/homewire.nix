{
  nixos.hosts.hestia =
    {
      my,
      pkgs,
      ...
    }:
    {
      imports = [ my.projects.homewire.nixosModules.default ];

      services.caddy.virtualHosts."wire.olii.nl".handler = ''
        reverse_proxy http://127.0.0.1:3030
      '';

      services.avahi = {
        enable = true;
        openFirewall = true;
      };

      services.homewire = {
        enable = true;
        environmentFile = "/var/lib/homewire/homewire.env";

        zigbee2mqtt = {
          enable = true;
          username = "zigbee";
        };

        esphome = {
          enable = true;
          discover = true;
        };

        studio = {
          enable = true;
          port = 3030;
        };

        functionalNodes.enable = true;
        syntheticNodes.enable = true;

        eventMaps = {
          "zigbee2mqtt/Philips/929002398602" = {
            on_press = "onoff.toggle";
            off_press = "onoff.off";
            up_press = "brightness.step_up";
            up_hold = "brightness.move_up";
            up_hold_release = "brightness.stop";
            down_press = "brightness.step_down";
            down_hold = "brightness.move_down";
            down_hold_release = "brightness.stop";
          };

          "zigbee2mqtt/Philips/8719514440937_8719514440999" = {
            button_1_press_release = "1.onoff.toggle";
            button_1_hold = "1.brightness.move_up";
            button_1_hold_release = "1.brightness.stop";
            button_2_press_release = "2.onoff.toggle";
            button_2_hold = "2.brightness.move_up";
            button_2_hold_release = "2.brightness.stop";
            button_3_press_release = "3.onoff.toggle";
            button_3_hold = "3.brightness.move_down";
            button_3_hold_release = "3.brightness.stop";
            button_4_press_release = "4.onoff.toggle";
            button_4_hold = "4.brightness.move_down";
            button_4_hold_release = "4.brightness.stop";
          };

          "zigbee2mqtt/Philips/9290030675" = {
            "occupancy.occupied" = "onoff.on";
            "occupancy.unoccupied" = "onoff.off";
          };
        };
      };

      olistrik.services.nixwarden.secrets."homewire.env" = [
        {
          location = "/var/lib/homewire/homewire.env";
          wantedBy = [ "homewire.service" ];
          userGroup = "homewire:homewire";
          permissions = "0400";
        }
      ];

      # One-time migration from the zellij-run database. The marker prevents
      # an old copy from being restored if the live database is ever removed.
      system.activationScripts.homewireDatabaseMigration = {
        deps = [
          "groups"
          "users"
        ];
        text = ''
          oldDatabase=/home/oli/homewire/homewire.db
          dataDirectory=/var/lib/homewire
          newDatabase=$dataDirectory/homewire.db
          migrationMarker=$dataDirectory/.zellij-database-migrated

          if [ ! -e "$migrationMarker" ]; then
            if [ -e "$newDatabase" ]; then
              echo "Homewire database exists without migration marker; refusing to overwrite it" >&2
              exit 1
            fi
            if [ ! -e "$oldDatabase" ]; then
              echo "Homewire zellij database not found at $oldDatabase" >&2
              exit 1
            fi

            checkpoint=$(${pkgs.sqlite}/bin/sqlite3 "$oldDatabase" 'PRAGMA wal_checkpoint(TRUNCATE);')
            case "$checkpoint" in
              0\|*) ;;
              *)
                echo "Homewire database checkpoint was busy: $checkpoint" >&2
                exit 1
                ;;
            esac

            ${pkgs.coreutils}/bin/install -d -m 0750 -o homewire -g homewire "$dataDirectory"
            ${pkgs.coreutils}/bin/install -m 0600 -o homewire -g homewire "$oldDatabase" "$newDatabase"
            ${pkgs.coreutils}/bin/install -m 0640 -o homewire -g homewire /dev/null "$migrationMarker"
          fi
        '';
      };
    };
}
