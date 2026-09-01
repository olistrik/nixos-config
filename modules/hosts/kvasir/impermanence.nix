{
  nixos.hosts.kvasir =
    {
      my,
      pkgs,
      ...
    }:
    {
      imports = [
        (my.sources.impermanence + "/nixos.nix")
      ];

      fileSystems."/persist".neededForBoot = true;

      environment.persistence."/persist" = {
        hideMounts = true;
        directories = [
          "/etc/NetworkManager/system-connections"
          "/var/log"
          "/var/lib/nixos"
          "/var/lib/systemd/coredump"
          "/var/lib/bluetooth"
          "/var/lib/tailscale"
        ];
        files = [
          "/etc/machine-id"
        ];
      };

      users.mutableUsers = false;

      boot.initrd.systemd.services.impermanence-btrfs-rollback = {
        description = "Restore the blank Btrfs root for impermanence";
        unitConfig.DefaultDependencies = false;
        serviceConfig.Type = "oneshot";

        requiredBy = [ "initrd.target" ];
        before = [ "sysroot.mount" ];
        requires = [ "dev-kvasir-system.device" ];
        after = [
          "dev-kvasir-system.device"
          "systemd-hibernate-resume.service"
        ];

        path = [
          pkgs.btrfs-progs
          pkgs.coreutils
          pkgs.findutils
          pkgs.util-linux
        ];

        script = ''
          set -euo pipefail

          btrfs_root="$(mktemp -d)"
          mount -t btrfs -o subvolid=5 /dev/kvasir/system "$btrfs_root"
          trap 'umount "$btrfs_root"; rmdir "$btrfs_root"' EXIT

          blank_root="$btrfs_root/@root-blank"
          current_root="$btrfs_root/@root"
          old_roots="$btrfs_root/@old_roots"

          if ! btrfs subvolume show "$blank_root" >/dev/null 2>&1; then
            echo "The blank root snapshot does not exist: $blank_root" >&2
            exit 1
          fi

          mkdir -p "$old_roots"
          if btrfs subvolume show "$current_root" >/dev/null 2>&1; then
            timestamp="$(date --date="@$(stat -c %Y "$current_root")" "+%Y-%m-%d_%H:%M:%S")"
            mv "$current_root" "$old_roots/$timestamp"
          fi

          # A read-only source snapshot produces a writable snapshot by default.
          btrfs subvolume snapshot "$blank_root" "$current_root"

          delete_subvolume_recursively() {
            local subvolume="$1"
            while IFS= read -r child; do
              btrfs subvolume delete "$btrfs_root/$child"
            done < <(
              btrfs subvolume list -o "$subvolume" \
                | cut -f 9- -d ' ' \
                | sort --reverse
            )
            btrfs subvolume delete "$subvolume"
          }

          while IFS= read -r old_root; do
            delete_subvolume_recursively "$old_root"
          done < <(find "$old_roots" -mindepth 1 -maxdepth 1 -mtime +30 -print)
        '';
      };
    };
}
