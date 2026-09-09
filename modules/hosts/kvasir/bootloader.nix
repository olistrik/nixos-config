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

      boot.lanzaboote = {
        enable = true;
        pkiBundle = "/var/lib/sbctl";
      };
    };
}
