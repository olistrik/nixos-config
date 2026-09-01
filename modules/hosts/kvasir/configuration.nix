{
  nixos.hosts.kvasir =
    { my, ... }:
    {
      imports = [
	./_hardware-configuration.nix

        my.modules.nixos.system.agenix
      ];

      age.identityPaths = [ "/persist/age/kvasir-identity" ];
      environment.shellAliases.agenix = "agenix -i /persist/age/kvasir-identity";

      system.stateVersion = "26.05";
    };
}
