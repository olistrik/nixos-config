{ ... }: {
  fileSystems."/persist".neededForBoot = true;
  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      # system
      "/var/log"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"

      # services
      "/var/lib/nixwarden"
      "/var/lib/tailscale"
      "/var/lib/acme"
      "/var/lib/nix-serve"

      # home assistant
      "/var/lib/mosquitto"
      "/var/lib/zigbee2mqtt"
      "/var/lib/node-red"

      # game servers
      "/var/lib/valheim"
      "/var/lib/palworld-server"

      # storage servers
      "/var/lib/immich"
      "/var/lib/postgresql"
    ];
    files = [
      # machine-id
      "/etc/machine-id"

      # ssh host keys
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
      # {
      #   environment.persistence."<dir>".files =
      #     lib.concatMap (key: [ key.path (key.path + ".pub") ]) config.services.openssh.hostKeys;
      # }
      # or just directly bind them.
    ];
  };
}
