{
  nixos.hosts.thoth =
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
          "/etc/NetworkManager/system-connections"
          "/var/log"
          "/var/lib/nixos"
          "/var/lib/systemd/coredump"
          "/var/lib/bluetooth"

          # services
          "/var/lib/tailscale"
          "/var/lib/docker"
        ];
        files = [
          # machine-id
          "/etc/machine-id"
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
        script = lib.concatStringsSep "\n" (map (snapshot: "${pkgs.zfs}/bin/zfs rollback -r ${snapshot}") snapshots);
      };
    };
}
