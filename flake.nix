{
  description = "Nix is love. Nix is life.";

  inputs = {
    nixosPkgs.url = "github:nixos/nixpkgs/nixos-20.09";

    unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    custom = {
      url = "/etc/nixos/nixpkgs-custom";
      flake = false;
    };

    secrets-dir = {
      url = "/etc/nixos/secrets";
      flake = false;
    };
  };

  outputs = inputs@{self, nixosPkgs, ...}: {
    nixosConfigurations = let
      secrets = import inputs.secrets-dir;
      unstable = import inputs.unstable { system = "x86_64-linux"; };
      custom = import inputs.custom { pkgs = nixosPkgs; };
    in {
      nixogen = nixosPkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit secrets unstable custom; };
        modules = [
          ./hosts/nixogen/configuration.nix
          custom.modules
        ];

      };
    };
  };
}
