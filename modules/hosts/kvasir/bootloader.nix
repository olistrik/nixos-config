{
  nixos.hosts.kvasir =
    {
      my,
      pkgs,
      lib,
      ...
    }:
    let
      lanzaboote = import my.sources.lanzaboote {
        inherit pkgs;
      };
    in
    {
      imports = [ lanzaboote.nixosModules.lanzaboote ];

      environment.systemPackages = [
        pkgs.sbctl
      ];

      boot.loader.systemd-boot.enable = lib.mkForce false;
      boot.loader.efi.canTouchEfiVariables = true;
      boot.loader.efi.efiSysMountPoint = "/boot/efi";

      boot.initrd.systemd.enable = true;

      boot.lanzaboote = {
        enable = true;
        pkiBundle = "/var/lib/sbctl";

        # systemd-pcrlock enforces this hard cap once measured boot is on.
        configurationLimit = 8;

        # PCRs 1-3 are flaky across firmware/hardware; 0 (firmware), 4
        # (boot loader/kernel image) and 7 (secure boot state) are the
        # set lanzaboote's own docs recommend and test against.
        measuredBoot = {
          enable = true;
          pcrs = [
            0
            4
            7
          ];
        };
      };
    };
}
