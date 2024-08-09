{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot/efi";
              };
            };
            swap = {
              size = "32G";
              content = {
                type = "swap";
                randomEncryption = true;
              };
            };
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zroot";
              };
            };
          };
        };
      };
    };
    zpool = {
      zroot = {
        type = "zpool";
        rootFsOptions = {
          acltype = "posixacl";
          atime = "off";
          # relatime="on"; # only takes effect with atime=on.
          xattr = "sa";
          dnodesize = "legacy"; # auto is an option with xattr=sa.
          normalization = "formD"; # unicode normalization of file names.
          mountpoint = "none";
          devices = "off";
          compression = "lz4";
        };
        options.ashift = "12";

        datasets = {
          "local" = {
            type = "zfs_fs";
            options = {
              mountpoint = "none";
	      encryption = "aes-256-gcm";
	      keyformat = "passphrase";
	      keylocation = "file:///tmp/encryption.key";
            };
	    postCreateHook = ''
	      zfs set keylocation="prompt" "zroot/$name"
	    '';
          };
          "local/root" = {
            type = "zfs_fs";
            mountpoint = "/";
            options."com.sun:auto-snapshot" = "false";
            postCreateHook = "zfs snapshot zroot/local/root@blank";
          };
          "local/nix" = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options."com.sun:auto-snapshot" = "false";
          };
          "local/home" = {
            # this isn't strictly necessary, but it allows for toggling imperminance for root and home seperately.
            type = "zfs_fs";
            mountpoint = "/home";
            options."com.sun:auto-snapshot" = "false";
            postCreateHook = "zfs snapshot zroot/local/home@blank";
          };
          "local/persist" = {
            type = "zfs_fs";
            mountpoint = "/persist";
            options."com.sun:auto-snapshot" = "false";
          };
          "local/persist/home" = {
            type = "zfs_fs";
            mountpoint = "/persist/home";
            options."com.sun:auto-snapshot" = "true";
          };
        };
      };
    };
  };
}
