{
  nixos.hosts.thoth =
    {
      my,
      lib,
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

      boot.initrd.postResumeCommands = lib.mkAfter (
        builtins.concatStringsSep "/n" (map (snapshot: "zfs rollback -r ${snapshot}") snapshots)
      );
    };
}
