{
  nixos.hosts.hestia =
    {
      lib,
      pkgs,
      ...
    }:
    let
      snapshots = [ "zroot/local/root@blank" ];
    in
    {
      environment.persistence."/persist" = {
        directories = [
          "/var/lib/systemd/coredump"

          # shared TLS material for every caddy virtualHost on this host.
          "/var/lib/acme"

          # WARN: these two modules aren't currently wired into
          # nixos.hosts.hestia (see the WARN comments in their own files),
          # so their persistence can't be colocated there without silently
          # dropping it.
          "/var/lib/valheim"
          "/var/lib/palworld-server"
        ];
        files = [
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
