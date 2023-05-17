{ nixpkgs, ... }: {
  boot.initrd.luks.devices.crypt-root = {
    device = "/dev/disk/by-label/CRYPT_ROOT";
  };
  fileSystems."/root".device = "/dev/mapper/crypt-root";
}
