{
  nixos.hosts.hestia =
    {
      my,
      lib,
      pkgs,
      config,
      ...
    }:
    let
      snapshots = [ "zroot/local/root@blank" ];
    in
    {
      imports = [
        (my.sources.impermanence + "/nixos.nix")
      ];

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
          "/var/lib/private/tsidp"

          # home assistant
          "/var/lib/mosquitto"
          "/var/lib/zigbee2mqtt"
          "/var/lib/node-red"

          # game servers
          "/var/lib/valheim"
          "/var/lib/palworld-server"

          # storage servers
          "/var/lib/immich"
          "/var/lib/redis-immich"
          "/var/lib/postgresql"
          "/var/lib/nextcloud"
          "/var/lib/redis-nextcloud"
          "/var/lib/hindsight"

          # msmtp
          "/var/lib/msmtp"
        ];
        files = [
          #log-rotate status
          "/var/lib/logrotate.status"

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

      # TODO: move somewhere better; or fix impermanence so
      # users can be mutable. /etc/shadow I think.
      users.mutableUsers = false;

      boot.zfs.forceImportRoot = true;
      boot.initrd.systemd.services.impermanence-zfs-rollback = {
        description = "Roll back ZFS root datasets for impermanence";
        unitConfig.DefaultDependencies = false;
        serviceConfig.Type = "oneshot";
        requiredBy = [ "initrd.target" ];
        before = [ "sysroot.mount" ];
        requires = [ "zfs-import.target" ];
        after = [
          "zfs-import.target"
          "local-fs-pre.target"
        ];
        script = lib.concatStringsSep "\n" (
          map (snapshot: "${pkgs.zfs}/bin/zfs rollback -r ${snapshot}") snapshots
        );
      };
    };
}
