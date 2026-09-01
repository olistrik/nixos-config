let
  btrfsMountOptions = [
    "compress=zstd"
    "noatime"
  ];
in
{
  disko.devices = {
    disk.main = {
      type = "disk";
      device = "/dev/nvme0n1";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot/efi";
              mountOptions = [ "umask=0077" ];
            };
          };

          luks = {
            size = "100%";
            type = "8309";
            content = {
              type = "luks";
              name = "cryptroot";
              extraFormatArgs = [
                "--type"
                "luks2"
              ];
              settings.allowDiscards = true;
              content = {
                type = "lvm_pv";
                vg = "kvasir";
              };
            };
          };
        };
      };
    };

    lvm_vg.kvasir = {
      type = "lvm_vg";
      lvs = {
        # This must be at least as large as the memory that may be in use when
        # hibernating. Keeping it as an LV gives the kernel a stable resume
        # device while leaving the swap encrypted by cryptroot.
        swap = {
          size = "48G";
          content = {
            type = "swap";
            resumeDevice = true;
          };
        };

        system = {
          size = "100%FREE";
          content = {
            type = "btrfs";
            extraArgs = [ "-f" ];

            # Remember whether this invocation created the filesystem so a
            # missing blank snapshot can never be recreated from a live system.
            preCreateHook = ''
              if blkid "$device" -o export | grep -q '^TYPE=btrfs$'; then
                filesystem_existed=1
              else
                filesystem_existed=0
              fi
            '';
            postCreateHook = ''
              if test "$filesystem_existed" = 0; then
                btrfs_root="$(mktemp -d)"
                mount "$device" "$btrfs_root" -o subvolid=5
                trap 'umount "$btrfs_root"; rmdir "$btrfs_root"' EXIT

                btrfs subvolume snapshot -r "$btrfs_root/@root" "$btrfs_root/@root-blank"
                btrfs subvolume snapshot -r "$btrfs_root/@home" "$btrfs_root/@home-blank"
              fi
            '';
            subvolumes = {
              "@root" = {
                mountpoint = "/";
                mountOptions = btrfsMountOptions;
              };
              "@nix" = {
                mountpoint = "/nix";
                mountOptions = btrfsMountOptions;
              };
              "@home" = {
                mountpoint = "/home";
                mountOptions = btrfsMountOptions;
              };
              "@persist" = {
                mountpoint = "/persist";
                mountOptions = btrfsMountOptions;
              };
            };
          };
        };
      };
    };
  };
}
