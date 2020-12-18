{
  description = "Nix is love. Nix is life.";

  inputs = {
    nixosPkgs.url = "github:nixos/nixpkgs/nixos-20.09";

    unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    secrets-dir = {
      url = "/etc/nixos/secrets";
      flake = false;
    };
  };

  outputs = inputs@{self, nixosPkgs, ...}: {
    nixosConfigurations = let
      secrets = import inputs.secrets-dir;
      unstable = import inputs.unstable { system = "x86_64-linux"; };
    in {
      nixogen = nixosPkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit secrets unstable; };
        modules = [ ./hosts/nixogen/configuration.nix ];
      };
    };
  };
}
