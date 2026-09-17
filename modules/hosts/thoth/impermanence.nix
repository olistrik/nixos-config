{
  nixos.hosts.thoth =
    { lib, pkgs, ... }:
    let
      snapshots = [ "zroot/local/root@blank" ];
    in
    {
      environment.persistence."/persist".directories = [
        "/var/lib/systemd/coredump"
      ];

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
