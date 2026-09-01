{
  nixos.hosts.kvasir =
    { my, ... }:
    {
      imports = [
        my.modules.nixos.system.agenix
      ];

      age.identityPaths = [ "/persist/age/kvasir-identity" ];
      environment.shellAliases.agenix = "agenix -i /persist/age/kvasir-identity";

      system.stateVersion = "26.05";
    };
}
