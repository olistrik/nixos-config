{
  nixos.hosts.thoth =
    { my, pkgs, ... }:
    {

      imports = with my.modules.nixos; [
        hardware.touchpad
        hardware.keyboard

        collections.personal
        collections.workstation

        services.printing

        programs.nix-ld

        programs.niri
        programs.ags

        programs.pulseview

        system.virtualisation
        system.agenix
      ];

      # TODO: put somewhere useful.
      documentation.nixos.enable = false;

      age.identityPaths = [ "/persist/age/thoth-identity" ];
      environment.shellAliases.agenix = "agenix -i /persist/age/thoth-identity";

      # Weird AMD stuff.
      hardware.cpu.amd.updateMicrocode = true;
      hardware.firmware = [ pkgs.linux-firmware ];

      # https://gist.github.com/danielrosehill/6a531b079906f160911a87dea50e1507
      boot.kernelParams = [
        # "amdgpu.sg_display=0"
        # "amdgpu.dcdebugmask=0x10"
        # "iommu=soft"
        "amdgpu.gpu_recovery=1"
        # "amdgpu.gfx_off=0"
        "amdgpu.runpm=0"
      ];
      # rocm?

      # TODO: put somewhere useful.
      environment.systemPackages = with pkgs; [
        nix-output-monitor # honestly don't know what this is.
        android-tools
      ];

      nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };

      # NEVER CHANGE.
      networking.hostId = "8177229e"; # Required for ZFS.
      system.stateVersion = "24.05"; # Did you read the comment?
    };
}
