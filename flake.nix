{
  description = "Nix is love. Nix is life.";

  inputs = {

    # Normal nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";

    # Unstable nixpkgs
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # nix2vim
    #nix2vim = {
    #  url = "github:kranex/nix2vim";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};

    # devenv
    devenv = {
      url = "github:cachix/devenv/latest";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Flake utils
    flake-utils.url = "github:numtide/flake-utils";

    # templates
    templates.url = "github:nixos/templates";

    # iso generator
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, nixos-generators, ... }@inputs:
    with flake-utils.lib;
    let
      # overlays on nixpkgs.
      nixpkgsConfig = with inputs; rec {
        config = { allowUnfree = true; };
        overlays = [
          (final: prev: {
            # pkgs.unstable
            unstable = import nixpkgs-unstable {
              inherit (prev) system;
              inherit config;
            };
            # pkgs.kranex
            kranex = final.callPackage ./pkgs { };
            devenv = devenv.packages."${prev.system}".devenv;
          })
          # inputs.nix2vim.overlay
        ];
      };

      pin-flake-reg = with inputs; {
        nix.registry.nixpkgs.flake = nixpkgs;
        nix.registry.unstable.flake = nixpkgs-unstable;
        nix.registry.kranex.flake = self;
        nix.registry.templates.flake = self;
      };

      # modules that are shared between all hosts.
      commonModules = [
        ({ nixpkgs = nixpkgsConfig; })
        pin-flake-reg # pin the pkgs.

        self.modules
        ./shared/default.nix # default programs and config for all systems.
      ];

      # shortcut for x86-64 linux systems.
      linux64 = host:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = commonModules
            ++ [ (./. + "/hosts/${host}/configuration.nix") ];
        };
    in {
      # My systems.
      nixosConfigurations = {
        ## Work Lenovo E15
        nixogen = linux64 "nixogen";

        ## Home Server
        hestia = linux64 "hestia";
      };

      packages.x86_64-linux = {
        ## Live USB
        liveUsb = nixos-generators.nixosGenerate {
          system = "x86_64-linux";
          modules = commonModules ++ [ ./hosts/live-usb/configuration.nix ];
          format = "install-iso";
        };
      } // flattenTree (import nixpkgs {
        inherit (nixpkgsConfig) config overlays;
        system = "x86_64-linux";
      }).kranex;

      # My modules, see commonModules for usage.
      modules = import ./modules;

      templates = inputs.templates.templates // import ./templates;
      defaultTemplate = self.templates.devshell;

    };
}
