{
  description = "Nix is love. Nix is life.";

  inputs = {
    # Pin nixpkgs to 20.09
    nixpkgs.url = "github:nixos/nixpkgs/nixos-20.09";

    # Unstable branch
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # My custom packages WIP
    nixpkgs-custom.url = "github:kranex/nixpkgs-custom";

    # where the secrets dir is.
    secrets-dir = {
      url = "/secrets";
      flake = false;
    };
  };

 outputs = inputs@{self, nixpkgs, ...}:
    let
      custom-modules = inputs.nixpkgs-custom.nixosModules.custom;
      # overlay unstable on nixpkgs. pkgs.unstable.[package] should now be
      # available.
      overlay-unstable = final: prev: {
        unstable = inputs.nixpkgs-unstable.legacyPackages.${final.system};
      };
      # import the secrets dir.
      secrets = import inputs.secrets-dir;
    in {
      nixosConfigurations = {
        ## Work Lenovo E15
        nixogen = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit secrets; };
          modules = [
            ({pkgs, ...}: { nixpkgs.overlays = [overlay-unstable]; })
            ./hosts/nixogen/configuration.nix
            custom-modules
          ];
        };
      };
    };
}
