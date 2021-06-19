{
  description = "Nix is love. Nix is life.";

  inputs = {
    # Pin nixpkgs to 20.09
    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.05";

    # Unstable branch
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # nvim 0.5
    neovim = {
      url = "github:neovim/neovim?dir=contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # My custom packages WIP
    nixpkgs-custom = {
      url = "github:kranex/nixpkgs-custom";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    secrets = {
      url = "/etc/nixos/secrets";
      flake = false;
    };

  };

 outputs = {self, nixpkgs, ... }@inputs:
    let
      custom-modules = inputs.nixpkgs-custom.nixosModules.custom;
      # overlay unstable on nixpkgs. pkgs.unstable.[package] should now be
      # available.
      nixpkgsConfig = with inputs; rec {
        config = { allowUnfree = true; };
        overlays = [
          (
            final: prev: {
              unstable =  import nixpkgs-unstable {
                inherit (prev) system; inherit config;
              };

              neovim-nightly = neovim.packages.${prev.system}.neovim;
              # Packages to be on bleeding edge.
              vimPlugins = prev.vimPlugins // final.unstable.vimPlugins;
            }
          )
        ];
      };

      # import the secrets dir.
      # secrets = import inputs.secrets-dir;
      secrets = (import inputs.secrets).secrets;

      commonModules = [
        custom-modules
        ({conifg, lib, ...}: { nixpkgs = nixpkgsConfig; })
      ];
    in {
      nixosConfigurations = {
        ## Work Lenovo E15
        nixogen = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit secrets; };
          modules = commonModules ++ [
            ./hosts/nixogen/configuration.nix
          ];
        };

        ## New PC
        nixium = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit secrets; };
          modules = commonModules ++ [
            ./hosts/nixium/configuration.nix
          ];
        };

        ## WSL 2
        winix = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit secrets; };
          modules = commonModules ++ [
            ./hosts/winix/configuration.nix
          ];
        };
      };
    };
}
