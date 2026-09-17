{
  # TODO: should probably go in nixos.system.wifi and nixos.system.bluetooth
  nixos.hosts.kvasir = {
    networking.networkmanager.enable = true;

    # This is a little bleh.
    users.users.oli.extraGroups = [
      "networkmanager"
    ];

    environment.persistence."/persist".directories = [
      "/etc/NetworkManager/system-connections"
      "/var/lib/bluetooth"
    ];

    hardware.bluetooth.enable = true;
    hardware.bluetooth.settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
      };
    };

    boot.extraModprobeConfig = ''
      options rtw89_pci disable_aspm_l1=1 disable_aspm_l1ss=1 disable_clkreq=1
    '';

    # Configure audio priority (WIP: The wireplumber docs are really confusing.)
    # TODO: make this cleaner.
    # headphones ? bluetooth > HDMI > Speaker
    services.pipewire.wireplumber.extraConfig."10-sink-priority" = {
      "monitor.alsa.rules" = [
        {
          matches = [
            {
              "node.name" = "~alsa_output.*";
              "device.profile.description" = "Speaker + Headphones";
              # With / Without headphones?
            }
          ];
          actions = {
            update-props = {
              "priority.driver" = "1000";
              "priority.session" = "1000";
            };
          };
        }
        {
          matches = [
            {
              "node.name" = "~alsa_output.*";
              "device.profile.description" = "HDMI / DisplayPort 1 Output";
            }
          ];
          actions = {
            update-props = {
              "priority.driver" = "500";
              "priority.session" = "500";
            };
          };
        }
        # bluetooth? monitor.bluez.rules
      ];
    };
  };
}
