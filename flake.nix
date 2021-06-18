{
  description = "Nix is love. Nix is life.";

  inputs = {
    # Pin nixpkgs to 20.09
    nixpkgs.url = "github:nixos/nixpkgs/nixos-20.09";

    # Unstable branch
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # My custom packages WIP
    nixpkgs-custom = {
      url = "github:kranex/nixpkgs-custom";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix.url = "github:Mic92/sops-nix";

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
        unstable =  import inputs.nixpkgs-unstable {
          system = "${final.system}";
          config.allowUnfree = true;
        };
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
            inputs.sops-nix.nixosModules.sops
          ];
        };
        ## Home PC
        nixbidium = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit secrets; };
          modules = [
            ({pkgs, ...}: { nixpkgs.overlays = [overlay-unstable]; })
            ./hosts/nixbidium/configuration.nix
            custom-modules
          ];
        };

        ## New PC
        nixium = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit secrets; };
          modules = [
            ({pkgs, ...}: { nixpkgs.overlays = [overlay-unstable]; })
            ./hosts/nixium/configuration.nix
            custom-modules
          ];
        };

        ## WSL 2
        winix = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit secrets; };
          modules = [
            ({pkgs, ...}: { nixpkgs.overlays = [overlay-unstable]; })
            ./hosts/winix/configuration.nix
            custom-modules
          ];
        };
      };
    };
}
