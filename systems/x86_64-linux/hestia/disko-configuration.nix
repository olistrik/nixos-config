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
						options.mountpoint = "none";
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
						type = "zfs_fs";
						mountpoint = "/home";
						options."com.sun:auto-snapshot" = "true";
					};
					"local/persist" = {
						type = "zfs_fs";
						mountpoint = "/persist";
						options."com.sun:auto-snapshot" = "false";
					};
				};
			};
		};
	};
}
