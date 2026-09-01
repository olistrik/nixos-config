{
  nixos.hosts.kvasir =
    { my, ... }:
    {
      imports = with my.modules.nixos; [
        ./_hardware-configuration.nix

        collections.personal
        collections.workstation

        programs.nix-ld

        programs.niri
        programs.ags
        programs.pulseview

        # system.virtualisation
        system.agenix
      ];

      age.identityPaths = [ "/persist/age/kvasir-identity" ];
      environment.shellAliases.agenix = "agenix -i /persist/age/kvasir-identity";

      networking.hostId = "007f0200";
      system.stateVersion = "26.05";
    };
}
