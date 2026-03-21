{
  nixos.hosts.thoth =
    { self, pkgs, ... }:
    {

      imports = with self.modules.nixos; [
        hardware.touchpad
        hardware.keyboard

        collections.personal
        collections.workstation

        services.printing

        programs.nix-ld

        programs.niri
        programs.ags

        system.virtualisation
      ];

      # TODO: put somewhere useful.
      documentation.nixos.enable = false;

      # Weird AMD stuff.
      hardware.cpu.amd.updateMicrocode = true;
      hardware.firmware = [ pkgs.linux-firmware ];
      # rocm?

      # TODO: put somewhere useful.
      programs.adb.enable = true;

      # TODO: put somewhere useful.
      environment.systemPackages = with pkgs; [
        nix-output-monitor # honestly don't know what this is.
      ];

      # NEVER CHANGE.
      networking.hostId = "8177229e"; # Required for ZFS.
      system.stateVersion = "24.05"; # Did you read the comment?
    };
}
